#include "Account.h"

Account::Account(QObject* parent) :
    QObject(parent) {}

Account::Account(const QString& name, QObject* parent) :
    QObject(parent), _name(name) {}

int Account::currentOperationIndex() const {
  if (!_currentOperation) return -1;
  return _operations.indexOf(_currentOperation);
}

void Account::set_currentOperationIndex(int index) {
  set_currentOperation(getOperation(index));
}

int Account::operationCount() const {
  return _operations.size();
}

QList<Operation*> Account::operations() const {
  return _operations;
}

void Account::addOperation(Operation* operation) {
  if (operation) {
    operation->setParent(this);
    // Insert in sorted order (most recent first)
    int insertIndex = 0;
    while (insertIndex < _operations.size() && _operations[insertIndex]->date() > operation->date()) {
      insertIndex++;
    }
    _operations.insert(insertIndex, operation);
    emit operationCountChanged();
  }
}

void Account::removeOperation(int index) {
  if (index >= 0 && index < _operations.size()) {
    Operation* op = _operations.takeAt(index);
    // Clear currentOperation if it was the deleted one
    if (_currentOperation == op) {
      set_currentOperation(nullptr);
    }
    delete op;
    emit operationCountChanged();
  }
}

bool Account::removeOperation(Operation* operation) {
  int index = _operations.indexOf(operation);
  if (index >= 0) {
    _operations.removeAt(index);
    // Clear currentOperation if it was the removed one
    if (_currentOperation == operation) {
      set_currentOperation(nullptr);
    }
    emit operationCountChanged();
    return true;
  }
  return false;
}

void Account::clearOperations() {
  qDeleteAll(_operations);
  _operations.clear();
  if (_currentOperation) {
    set_currentOperation(nullptr);
  }
  emit operationCountChanged();
}

void Account::sortOperations() {
  std::sort(_operations.begin(), _operations.end(), [](Operation* a, Operation* b) {
    return a->date() > b->date();  // Most recent first
  });
  // The index of currentOperation may have changed after sorting
  if (_currentOperation) {
    emit currentOperationChanged();
  }
}

bool Account::hasOperation(const QDate& date, double amount, const QString& description) const {
  for (Operation* op : _operations) {
    if (op->date() == date && op->amount() == amount && op->description() == description) {
      return true;
    }
  }
  return false;
}

Operation* Account::getOperation(int index) const {
  if (index >= 0 && index < _operations.size()) {
    return _operations[index];
  }
  return nullptr;
}
