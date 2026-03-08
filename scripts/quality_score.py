#!/usr/bin/env python3
"""
Quality Scoring System for Academic Course Materials

Calculates objective quality scores (0-100) based on defined rubrics.
Enforces quality gates: 80 (commit), 90 (PR), 95 (excellence).

Usage:
    python scripts/quality_score.py Slides/file.tex
    python scripts/quality_score.py scripts/analysis.py
    python scripts/quality_score.py notebooks/analysis.ipynb
    python scripts/quality_score.py scripts/*.py --summary
"""

import sys
import argparse
import subprocess
import json
import re
from pathlib import Path
from typing import Dict, List, Tuple


# ==============================================================================
# SCORING RUBRICS (from .claude/rules/quality-gates.md)
# ==============================================================================

BEAMER_RUBRIC = {
    "critical": {
        "compilation_failure": {"points": 100, "auto_fail": True},
        "undefined_citation": {"points": 15},
        "overfull_hbox": {"points": 10},
    },
    "major": {
        "text_overflow": {"points": 5},
        "notation_inconsistency": {"points": 3},
    },
    "minor": {
        "font_size_reduction": {"points": 1},
    },
}

PYTHON_RUBRIC = {
    "critical": {
        "syntax_error": {"points": 100, "auto_fail": True},
        "hardcoded_path": {"points": 20},
        "import_error": {"points": 15},
    },
    "major": {
        "missing_seed": {"points": 10},
        "no_output_files": {"points": 5},
        "missing_type_annotation": {"points": 3},
    },
    "minor": {
        "pep8_violation": {"points": 1},
        "missing_docstring": {"points": 1},
    },
}

NOTEBOOK_RUBRIC = {
    "critical": {
        "execution_failure": {"points": 100, "auto_fail": True},
        "hardcoded_path": {"points": 20},
    },
    "major": {
        "hidden_state": {"points": 15},
        "missing_seed": {"points": 10},
        "output_not_in_output_dir": {"points": 5},
    },
    "minor": {
        "no_markdown_context": {"points": 2},
        "committed_with_outputs": {"points": 1},
    },
}

THRESHOLDS = {"commit": 80, "pr": 90, "excellence": 95}


# ==============================================================================
# ISSUE DETECTION
# ==============================================================================


class IssueDetector:
    """Detect common issues for quality scoring."""

    @staticmethod
    def check_python_syntax(filepath: Path) -> Tuple[bool, str]:
        """Check Python script for syntax errors."""
        try:
            result = subprocess.run(
                [sys.executable, "-m", "py_compile", str(filepath)],
                capture_output=True,
                text=True,
                timeout=10,
            )
            if result.returncode != 0:
                return False, result.stderr
            return True, ""
        except subprocess.TimeoutExpired:
            return False, "Syntax check timeout"

    @staticmethod
    def check_notebook_execution(filepath: Path) -> Tuple[bool, str]:
        """Check if Jupyter notebook executes without errors."""
        output_path = Path("/tmp") / f"_verify_{filepath.stem}.ipynb"
        try:
            result = subprocess.run(
                [
                    "jupyter",
                    "nbconvert",
                    "--to",
                    "notebook",
                    "--execute",
                    str(filepath),
                    "--output",
                    str(output_path),
                    "--ExecutePreprocessor.timeout=120",
                ],
                capture_output=True,
                text=True,
                timeout=150,
            )
            if result.returncode != 0:
                return False, result.stderr[:300]
            return True, ""
        except subprocess.TimeoutExpired:
            return False, "Notebook execution timeout (>2.5min)"
        except FileNotFoundError:
            return False, "jupyter not installed or not in PATH"

    @staticmethod
    def check_hardcoded_paths(content: str) -> List[int]:
        """Detect absolute paths in Python scripts or notebooks."""
        issues = []
        lines = content.split("\n")
        for i, line in enumerate(lines, 1):
            if re.search(r'["\'][/\\](?!tmp)|["\'][A-Za-z]:[/\\]', line):
                if not re.search(r"http:|https:|file://", line):
                    issues.append(i)
        return issues

    @staticmethod
    def check_random_seed(content: str) -> bool:
        """Check if random seed is set when stochastic operations are used."""
        stochastic = ["np.random", "random.random", "random.seed", "torch.manual_seed",
                      "numpy.random", "sklearn", "sample(", "shuffle("]
        seed_patterns = ["random.seed", "np.random.seed", "numpy.random.seed",
                         "torch.manual_seed", "set_random_state"]
        has_stochastic = any(s in content for s in stochastic)
        has_seed = any(s in content for s in seed_patterns)
        return not (has_stochastic and not has_seed)

    @staticmethod
    def check_broken_citations(content: str, bib_file: Path) -> List[str]:
        """Check for LaTeX citation keys not in bibliography."""
        cite_pattern = r"\\cite[a-z]*\{([^}]+)\}"
        cited_keys: set = set()
        for match in re.finditer(cite_pattern, content):
            keys = match.group(1).split(",")
            cited_keys.update(k.strip() for k in keys)

        if not bib_file.exists():
            return list(cited_keys)

        bib_content = bib_file.read_text(encoding="utf-8")
        bib_keys = set(re.findall(r"@\w+\{([^,]+),", bib_content))
        return list(cited_keys - bib_keys)

    @staticmethod
    def check_latex_syntax(content: str) -> List[Dict]:
        """Check for common LaTeX syntax issues without compiling."""
        issues = []
        lines = content.split("\n")
        env_stack = []
        for i, line in enumerate(lines, 1):
            stripped = line.split("%")[0] if "%" in line else line
            for match in re.finditer(r"\\begin\{(\w+)\}", stripped):
                env_stack.append((match.group(1), i))
            for match in re.finditer(r"\\end\{(\w+)\}", stripped):
                env_name = match.group(1)
                if env_stack and env_stack[-1][0] == env_name:
                    env_stack.pop()
                elif env_stack:
                    issues.append({
                        "line": i,
                        "description": (
                            f"Mismatched environment: \\end{{{env_name}}} "
                            f"but expected \\end{{{env_stack[-1][0]}}} "
                            f"(opened at line {env_stack[-1][1]})"
                        ),
                    })
                else:
                    issues.append({
                        "line": i,
                        "description": f"\\end{{{env_name}}} without matching \\begin",
                    })
        for env_name, line_num in env_stack:
            issues.append({
                "line": line_num,
                "description": f"Unclosed environment: \\begin{{{env_name}}} never closed",
            })
        return issues

    @staticmethod
    def check_overfull_hbox_risk(content: str) -> List[int]:
        """Detect lines in LaTeX source likely to cause overfull hbox."""
        issues = []
        lines = content.split("\n")
        in_frame = False
        for i, line in enumerate(lines, 1):
            stripped = line.split("%")[0] if "%" in line else line
            if r"\begin{frame}" in stripped:
                in_frame = True
            elif r"\end{frame}" in stripped:
                in_frame = False
            if in_frame and len(stripped.strip()) > 120:
                if stripped.strip().startswith("%"):
                    continue
                if re.match(r"\s*\\(includegraphics|input|bibliography|usepackage)", stripped):
                    continue
                issues.append(i)
        return issues

    @staticmethod
    def check_equation_overflow(content: str) -> List[int]:
        """Detect displayed equations with single lines likely to overflow (>120 chars)."""
        overflows = []
        lines = content.split("\n")
        in_math = False
        math_delim = None

        for i, line in enumerate(lines, 1):
            stripped = line.strip()
            if "$$" in stripped and math_delim != "env":
                if not in_math:
                    in_math = True
                    math_delim = "$$"
                    if stripped.count("$$") >= 2:
                        inner = stripped.split("$$")[1]
                        if len(inner.strip()) > 120:
                            overflows.append(i)
                        in_math = False
                        math_delim = None
                else:
                    in_math = False
                    math_delim = None
                continue

            env_begin = re.match(
                r"\\begin\{(equation|align|gather|multline|eqnarray)\*?\}", stripped
            )
            if env_begin and not in_math:
                in_math = True
                math_delim = "env"
                continue

            if re.match(r"\\end\{(equation|align|gather|multline|eqnarray)\*?\}", stripped):
                in_math = False
                math_delim = None
                continue

            if in_math:
                code_part = line.split("%")[0] if "%" in line else line
                if len(code_part.strip()) > 120:
                    overflows.append(i)

        return overflows


# ==============================================================================
# QUALITY SCORER
# ==============================================================================


class QualityScorer:
    """Calculate quality scores for course materials."""

    def __init__(self, filepath: Path, verbose: bool = False) -> None:
        self.filepath = filepath
        self.verbose = verbose
        self.score = 100
        self.issues: Dict[str, List[Dict]] = {"critical": [], "major": [], "minor": []}
        self.auto_fail = False

    def _add_issue(self, severity: str, issue_type: str, description: str,
                   details: str, points: int) -> None:
        self.issues[severity].append({
            "type": issue_type,
            "description": description,
            "details": details,
            "points": points,
        })
        if severity == "critical":
            self.score -= points

    def score_beamer(self) -> Dict:
        """Score Beamer/LaTeX slides."""
        content = self.filepath.read_text(encoding="utf-8")

        syntax_issues = IssueDetector.check_latex_syntax(content)
        if syntax_issues:
            for issue in syntax_issues:
                self._add_issue(
                    "critical", "compilation_failure",
                    f"LaTeX syntax issue at line {issue['line']}",
                    issue["description"], 100,
                )
            self.auto_fail = True
            self.score = 0
            return self._generate_report()

        bib_file = self.filepath.parent.parent / "Bibliography_base.bib"
        if not bib_file.exists():
            bib_file = self.filepath.parent / "Bibliography_base.bib"
        for key in IssueDetector.check_broken_citations(content, bib_file):
            self._add_issue(
                "critical", "undefined_citation",
                f"Citation key not in bibliography: {key}",
                "Add to Bibliography_base.bib or fix key", 15,
            )

        for line in IssueDetector.check_overfull_hbox_risk(content):
            self._add_issue(
                "critical", "overfull_hbox",
                f"Potential overfull hbox at line {line}",
                "Line >120 chars inside frame may overflow slide width", 10,
            )

        for line in IssueDetector.check_equation_overflow(content):
            self._add_issue(
                "critical", "overfull_hbox",
                f"Potential equation overflow at line {line}",
                "Single equation line >120 chars likely to overflow", 10,
            )

        self.score = max(0, self.score)
        return self._generate_report()

    def score_python(self) -> Dict:
        """Score Python script quality."""
        content = self.filepath.read_text(encoding="utf-8")

        is_valid, error = IssueDetector.check_python_syntax(self.filepath)
        if not is_valid:
            self.auto_fail = True
            self._add_issue("critical", "syntax_error", "Python syntax error",
                            error[:200], 100)
            self.score = 0
            return self._generate_report()

        for line in IssueDetector.check_hardcoded_paths(content):
            self._add_issue(
                "critical", "hardcoded_path",
                f"Hardcoded absolute path at line {line}",
                "Use pathlib.Path relative to project root or __file__", 20,
            )

        if not IssueDetector.check_random_seed(content):
            self.issues["major"].append({
                "type": "missing_seed",
                "description": "Missing random seed for reproducibility",
                "details": "Add random.seed(42), np.random.seed(42) before stochastic calls",
                "points": 10,
            })
            self.score -= 10

        self.score = max(0, self.score)
        return self._generate_report()

    def score_notebook(self) -> Dict:
        """Score Jupyter notebook quality."""
        content = self.filepath.read_text(encoding="utf-8")

        for line in IssueDetector.check_hardcoded_paths(content):
            self._add_issue(
                "critical", "hardcoded_path",
                f"Hardcoded absolute path at/near line {line}",
                "Use pathlib.Path relative to project root", 20,
            )

        if not IssueDetector.check_random_seed(content):
            self.issues["major"].append({
                "type": "missing_seed",
                "description": "Missing random seed for reproducibility",
                "details": "Add random.seed(42), np.random.seed(42) in a setup cell",
                "points": 10,
            })
            self.score -= 10

        self.score = max(0, self.score)
        return self._generate_report()

    def _generate_report(self) -> Dict:
        """Generate quality score report."""
        if self.auto_fail:
            status = "FAIL"
        elif self.score >= THRESHOLDS["excellence"]:
            status = "EXCELLENCE"
        elif self.score >= THRESHOLDS["pr"]:
            status = "PR_READY"
        elif self.score >= THRESHOLDS["commit"]:
            status = "COMMIT_READY"
        else:
            status = "BLOCKED"

        counts = {
            k: len(v) for k, v in self.issues.items()
        }
        counts["total"] = sum(counts.values())

        return {
            "filepath": str(self.filepath),
            "score": self.score,
            "status": status,
            "auto_fail": self.auto_fail,
            "issues": {**self.issues, "counts": counts},
            "thresholds": THRESHOLDS,
        }

    def print_report(self, summary_only: bool = False) -> None:
        """Print formatted quality report."""
        report = self._generate_report()
        print(f"\n# Quality Score: {self.filepath.name}\n")

        labels = {
            "EXCELLENCE": "[EXCELLENCE]",
            "PR_READY": "[PASS]",
            "COMMIT_READY": "[PASS]",
            "BLOCKED": "[BLOCKED]",
            "FAIL": "[FAIL]",
        }
        print(f"## Overall Score: {report['score']}/100 {labels.get(report['status'], '')}")

        if report["status"] == "BLOCKED":
            print(f"\n**Status:** BLOCKED — Cannot commit (score < {THRESHOLDS['commit']})")
        elif report["status"] == "COMMIT_READY":
            gap = THRESHOLDS["pr"] - report["score"]
            print(f"\n**Status:** Ready for commit (score >= {THRESHOLDS['commit']})")
            print(f"**Gap to PR threshold:** +{gap} points needed")
        elif report["status"] == "PR_READY":
            gap = THRESHOLDS["excellence"] - report["score"]
            print(f"\n**Status:** Ready for PR (score >= {THRESHOLDS['pr']})")
            if gap > 0:
                print(f"**Gap to excellence:** +{gap} points needed")
        elif report["status"] == "EXCELLENCE":
            print(f"\n**Status:** Excellence achieved! (score >= {THRESHOLDS['excellence']})")
        elif report["status"] == "FAIL":
            print("\n**Status:** Auto-fail (syntax/compilation error)")

        counts = report["issues"]["counts"]
        if summary_only:
            print(
                f"\n**Total issues:** {counts['total']} "
                f"({counts['critical']} critical, {counts['major']} major, "
                f"{counts['minor']} minor)"
            )
            return

        print(f"\n## Critical Issues (MUST FIX): {counts['critical']}")
        if counts["critical"] == 0:
            print("None\n")
        else:
            for i, issue in enumerate(report["issues"]["critical"], 1):
                print(f"{i}. **{issue['description']}** (-{issue['points']} points)")
                print(f"   {issue['details']}\n")

        if counts["major"] > 0:
            print(f"## Major Issues (SHOULD FIX): {counts['major']}")
            for i, issue in enumerate(report["issues"]["major"], 1):
                print(f"{i}. **{issue['description']}** (-{issue['points']} points)")
                print(f"   {issue['details']}\n")

        if counts["minor"] > 0 and self.verbose:
            print(f"## Minor Issues (NICE-TO-HAVE): {counts['minor']}")
            for i, issue in enumerate(report["issues"]["minor"], 1):
                print(f"{i}. {issue['description']} (-{issue['points']} points)\n")


# ==============================================================================
# CLI INTERFACE
# ==============================================================================


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Calculate quality scores for course materials",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  # Score a Beamer/LaTeX file
  python scripts/quality_score.py Slides/Lecture01_Topic.tex

  # Score a Python script
  python scripts/quality_score.py scripts/analysis.py

  # Score a Jupyter notebook
  python scripts/quality_score.py notebooks/eda.ipynb

  # Score multiple files
  python scripts/quality_score.py scripts/*.py

  # Summary only (no detailed issues)
  python scripts/quality_score.py scripts/analysis.py --summary

  # Verbose output (include minor issues)
  python scripts/quality_score.py scripts/analysis.py --verbose

Quality Thresholds:
  80/100 = Commit threshold (blocks if below)
  90/100 = PR threshold (warning if below)
  95/100 = Excellence (aspirational)

Exit Codes:
  0 = Score >= 80 (commit allowed)
  1 = Score < 80 (commit blocked)
  2 = Auto-fail (syntax/compilation error)
        """,
    )
    parser.add_argument("filepaths", type=Path, nargs="+", help="Path(s) to file(s) to score")
    parser.add_argument("--summary", action="store_true", help="Show summary only")
    parser.add_argument("--verbose", action="store_true", help="Show all issues including minor")
    parser.add_argument("--json", action="store_true", help="Output as JSON")

    args = parser.parse_args()
    results = []
    exit_code = 0

    for filepath in args.filepaths:
        if not filepath.exists():
            print(f"Error: File not found: {filepath}")
            exit_code = 1
            continue

        try:
            scorer = QualityScorer(filepath, verbose=args.verbose)

            if filepath.suffix == ".tex":
                report = scorer.score_beamer()
            elif filepath.suffix == ".py":
                report = scorer.score_python()
            elif filepath.suffix == ".ipynb":
                report = scorer.score_notebook()
            else:
                print(f"Error: Unsupported file type: {filepath.suffix}")
                continue

            results.append(report)

            if not args.json:
                scorer.print_report(summary_only=args.summary)

            if report["auto_fail"]:
                exit_code = max(exit_code, 2)
            elif report["score"] < THRESHOLDS["commit"]:
                exit_code = max(exit_code, 1)

        except Exception as e:
            print(f"Error scoring {filepath}: {e}")
            import traceback
            traceback.print_exc()
            exit_code = 1

    if args.json:
        print(json.dumps(results, indent=2))

    sys.exit(exit_code)


if __name__ == "__main__":
    main()
