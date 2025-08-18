# OpenPage Documentation

## 📚 **Documentation Overview**

This directory contains all project documentation for OpenPage - the iA Writer + AI text editor.

### **Core Documents**

| Document | Purpose | When to Read |
|----------|---------|--------------|
| [PROJECT_PLAN.md](./PROJECT_PLAN.md) | Complete roadmap with epics, sprints, and implementation plan | Start of project, sprint planning |
| [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) | Best practices, architecture patterns, and common pitfalls | Before any coding, when stuck |
| [ARCHITECTURE_DECISION_LOG.md](./ARCHITECTURE_DECISION_LOG.md) | Record of all architectural decisions and rationales | When understanding past decisions |
| [SESSION_STATE.md](./SESSION_STATE.md) | Current development status and next steps | **Every session start** |

### **Quick Navigation**

#### **🚀 Starting Development?**
1. Read [SESSION_STATE.md](./SESSION_STATE.md) - Know where we are
2. Check [PROJECT_PLAN.md](./PROJECT_PLAN.md) - Understand current epic/sprint  
3. Review [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) - Follow established patterns

#### **🔍 Looking for Specific Information?**
- **Project Vision & Roadmap** → [PROJECT_PLAN.md](./PROJECT_PLAN.md)
- **Code Architecture & Patterns** → [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
- **Why We Made X Decision** → [ARCHITECTURE_DECISION_LOG.md](./ARCHITECTURE_DECISION_LOG.md)
- **Current Status & Next Steps** → [SESSION_STATE.md](./SESSION_STATE.md)

#### **🏗️ Making Architectural Changes?**
1. Check [ARCHITECTURE_DECISION_LOG.md](./ARCHITECTURE_DECISION_LOG.md) for context
2. Follow patterns in [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md)
3. Document new decisions in [ARCHITECTURE_DECISION_LOG.md](./ARCHITECTURE_DECISION_LOG.md)
4. Update [SESSION_STATE.md](./SESSION_STATE.md) with changes

### **Project Structure Overview**

```
OpenPage/
├── docs/                          # 📚 All documentation
│   ├── README.md                  # This file
│   ├── PROJECT_PLAN.md            # Complete roadmap
│   ├── DEVELOPMENT_GUIDE.md       # Best practices
│   ├── ARCHITECTURE_DECISION_LOG.md # Decision history
│   └── SESSION_STATE.md           # Current status
├── OpenPage/                      # 💻 Source code
│   ├── Models/                    # Data structures
│   ├── Services/                  # Business logic
│   ├── ViewModels/               # State management
│   ├── Views/                    # UI components
│   └── Extensions/               # Swift extensions
├── CLAUDE.md                     # 🤖 Claude Code guidance
└── README.md                     # Project overview
```

## 🎯 **Development Workflow**

### **Every Session Must:**
1. **Start** by reading [SESSION_STATE.md](./SESSION_STATE.md)
2. **Plan** work based on [PROJECT_PLAN.md](./PROJECT_PLAN.md) priorities
3. **Implement** following [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md) patterns
4. **Document** decisions in [ARCHITECTURE_DECISION_LOG.md](./ARCHITECTURE_DECISION_LOG.md)
5. **Update** [SESSION_STATE.md](./SESSION_STATE.md) with progress

### **Quality Standards**
All code must follow patterns established in [DEVELOPMENT_GUIDE.md](./DEVELOPMENT_GUIDE.md):
- ✅ MVVM + Services architecture
- ✅ Single source of truth for content
- ✅ Proper memory management
- ✅ No circular update loops
- ✅ Performance-first text operations

---

*For Claude Code: Always start new sessions by reading SESSION_STATE.md to understand current context and priorities.*