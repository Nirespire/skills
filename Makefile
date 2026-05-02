CLAUDE_SKILLS ?= $(HOME)/.claude/skills
SKILL_DIRS    := $(patsubst %/SKILL.md,%,$(shell find skills -mindepth 3 -maxdepth 3 -name SKILL.md))

.PHONY: help list install-claude uninstall-claude
.DEFAULT_GOAL := help

help:
	@printf "Personal skills repo.\n\n"
	@printf "Targets:\n"
	@printf "  list               List every skill in the repo\n"
	@printf "  install-claude     Symlink all skills into \$$(CLAUDE_SKILLS)\n"
	@printf "  uninstall-claude   Remove only symlinks that point back into this repo\n\n"
	@printf "Variables:\n"
	@printf "  CLAUDE_SKILLS  destination dir (default: %s)\n" "$(CLAUDE_SKILLS)"

list:
	@for d in $(SKILL_DIRS); do \
	  echo "$${d#skills/}"; \
	done

install-claude:
	@mkdir -p $(CLAUDE_SKILLS)
	@for d in $(SKILL_DIRS); do \
	  name=$$(basename $$d); \
	  target=$(CLAUDE_SKILLS)/$$name; \
	  if [ -e $$target ] && [ ! -L $$target ]; then \
	    echo "ERROR: $$target exists and is not a symlink — refusing to overwrite"; \
	    exit 1; \
	  fi; \
	  ln -sfn $(CURDIR)/$$d $$target; \
	  echo "linked $$name -> $(CURDIR)/$$d"; \
	done

uninstall-claude:
	@for d in $(SKILL_DIRS); do \
	  name=$$(basename $$d); \
	  target=$(CLAUDE_SKILLS)/$$name; \
	  if [ -L $$target ]; then \
	    dest=$$(readlink $$target); \
	    case $$dest in \
	      $(CURDIR)/*) rm $$target; echo "removed $$name";; \
	      *) echo "skipped $$name (symlink points outside repo: $$dest)";; \
	    esac; \
	  elif [ -e $$target ]; then \
	    echo "skipped $$name (not a symlink)"; \
	  fi; \
	done
