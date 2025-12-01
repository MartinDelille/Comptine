#pragma once

// Macro for read-write Qt properties with automatic getter, setter, signal, and member
// Usage: PROPERTY_RW(int, selectedOperationIndex, 0)
// Generates:
//   - Q_PROPERTY declaration with WRITE (exposed to QML)
//   - Type name() const getter
//   - Q_INVOKABLE void set_name(Type value) setter with change detection
//   - void nameChanged() signal
//   - Type _name member variable with default value

#define PROPERTY_RW(Type, name, defaultValue)                                  \
  Q_PROPERTY(Type name READ name WRITE set_##name NOTIFY name##Changed)        \
public:                                                                        \
  Type name() const { return _##name; }                                        \
  Q_INVOKABLE void set_##name(Type value) {                                    \
    if (_##name != value) {                                                    \
      _##name = value;                                                         \
      emit name##Changed();                                                    \
    }                                                                          \
  }                                                                            \
Q_SIGNALS:                                                                     \
  void name##Changed();                                                        \
private:                                                                       \
  Type _##name = defaultValue;

// Macro for properties writable from C++ but read-only from QML
// Usage: PROPERTY_RW_INTERNAL(double, amount, 0.0)
// Generates:
//   - Q_PROPERTY declaration without WRITE (read-only from QML)
//   - Type name() const getter
//   - void set_name(Type value) setter (C++ only, not Q_INVOKABLE)
//   - void nameChanged() signal
//   - Type _name member variable with default value

#define PROPERTY_RW_INTERNAL(Type, name, defaultValue)                         \
  Q_PROPERTY(Type name READ name NOTIFY name##Changed)                         \
public:                                                                        \
  Type name() const { return _##name; }                                        \
  void set_##name(Type value) {                                                \
    if (_##name != value) {                                                    \
      _##name = value;                                                         \
      emit name##Changed();                                                    \
    }                                                                          \
  }                                                                            \
Q_SIGNALS:                                                                     \
  void name##Changed();                                                        \
private:                                                                       \
  Type _##name = defaultValue;

// Macro for read-only Qt properties with declared getter (implemented in .cpp)
// Usage: PROPERTY_RO(int, accountCount)
// Generates:
//   - Q_PROPERTY declaration (read-only)
//   - Type name() const getter declaration (you implement in .cpp)
//   - void nameChanged() signal

#define PROPERTY_RO(Type, name)                                                \
  Q_PROPERTY(Type name READ name NOTIFY name##Changed)                         \
public:                                                                        \
  Type name() const;                                                           \
Q_SIGNALS:                                                                     \
  void name##Changed();                                                        \
private:

// Macro for read-write Qt properties with custom getter/setter (implemented in .cpp)
// Usage: PROPERTY_RW_CUSTOM(int, currentAccountIndex, -1)
// Generates:
//   - Q_PROPERTY declaration with WRITE
//   - Type name() const getter declaration (you implement in .cpp)
//   - Q_INVOKABLE void set_name(Type value) setter declaration (you implement in .cpp)
//   - void nameChanged() signal
//   - Type _name member variable with default value

#define PROPERTY_RW_CUSTOM(Type, name, defaultValue)                           \
  Q_PROPERTY(Type name READ name WRITE set_##name NOTIFY name##Changed)        \
public:                                                                        \
  Type name() const;                                                           \
  Q_INVOKABLE void set_##name(Type value);                                     \
Q_SIGNALS:                                                                     \
  void name##Changed();                                                        \
private:                                                                       \
  Type _##name = defaultValue;

