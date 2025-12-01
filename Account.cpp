#include "Account.h"

Account::Account(QObject *parent) : QObject(parent) {}

Account::Account(const QString &name, double balance, QObject *parent)
    : QObject(parent), _name(name), _balance(balance) {}

int Account::operationCount() const {
  return _operations.size();
}

QList<Operation *> Account::operations() const {
  return _operations;
}

void Account::addOperation(Operation *operation) {
  if (operation) {
    operation->setParent(this);
    _operations.append(operation);
    emit operationCountChanged();
  }
}

void Account::removeOperation(int index) {
  if (index >= 0 && index < _operations.size()) {
    delete _operations.takeAt(index);
    emit operationCountChanged();
  }
}

void Account::clearOperations() {
  qDeleteAll(_operations);
  _operations.clear();
  emit operationCountChanged();
}

Operation *Account::getOperation(int index) const {
  if (index >= 0 && index < _operations.size()) {
    return _operations[index];
  }
  return nullptr;
}
