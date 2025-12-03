# Contributing to Focus Session Watcher

Thanks for considering contributing! Here's how you can help:

## Reporting Bugs

1. Use the GitHub Issues page
2. Include:
   - Your macOS version (`sw_vers`)
   - Step-by-step reproduction
   - Expected vs actual behavior
   - Relevant log output from `/tmp/watch_inactivity_simple.log`

## Suggesting Enhancements

- Feature requests welcome!
- Discuss in Issues or Discussions tab
- Include use case and expected behavior

## Development

### Setup
```bash
git clone <your-fork>
cd focus-session-installer
```

### Testing Changes
```bash
# Test your changes locally
bash install.sh
# ... test the functionality ...
bash uninstall.sh
```

### Code Style
- Use zsh for shell scripts
- Add comments for complex logic
- Keep scripts simple and focused
- Test on your own system first

## Pull Request Process

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-thing`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages (`git commit -m "Add feature X"`)
6. Push to your fork (`git push origin feature/amazing-thing`)
7. Open a PR describing your changes

## Areas for Contribution

- Bug fixes
- Documentation improvements
- Shell script optimizations
- Shortcut enhancements
- Additional helper scripts
- Configuration examples
- Troubleshooting guide additions

---

**Thank you for making Focus Session Watcher better!** 🚀
