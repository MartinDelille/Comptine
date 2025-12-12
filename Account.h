#pragma once

#include <QList>
#include <QObject>
#include <QQmlEngine>
#include <QString>

#include "Operation.h"
#include "PropertyMacros.h"

class Account : public QObject {
  Q_OBJECT
  QML_ELEMENT
  PROPERTY_RW(QString, name, QString())
  PROPERTY_RO(int, operationCount)
  PROPERTY_RW(Operation*, currentOperation, nullptr)

  // Computed property: index of currentOperation in operations list
  // Uses currentOperationChanged signal since it changes when currentOperation changes
  Q_PROPERTY(int currentOperationIndex READ currentOperationIndex WRITE set_currentOperationIndex
                 NOTIFY currentOperationChanged)

public:
  explicit Account(QObject* parent = nullptr);
  explicit Account(const QString& name, QObject* parent = nullptr);

  // Current operation index (computed from currentOperation pointer)
  int currentOperationIndex() const;
  void set_currentOperationIndex(int index);

  QList<Operation*> operations() const;

  void addOperation(Operation* operation);
  void removeOperation(int index);
  bool removeOperation(Operation* operation);  // Remove by pointer, returns true if found
  void clearOperations();
  void sortOperations();  // Re-sort operations by date (most recent first)
  bool hasOperation(const QDate& date, double amount, const QString& description) const;

  Q_INVOKABLE Operation* getOperation(int index) const;

private:
  QList<Operation*> _operations;
};
