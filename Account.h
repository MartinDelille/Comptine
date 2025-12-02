#pragma once

#include <QList>
#include <QObject>
#include <QString>

#include "Operation.h"
#include "PropertyMacros.h"

class Account : public QObject {
  Q_OBJECT
  PROPERTY_RW(QString, name, QString())
  PROPERTY_RW(double, balance, 0.0)
  PROPERTY_RO(int, operationCount)

public:
  explicit Account(QObject *parent = nullptr);
  Account(const QString &name, double balance, QObject *parent = nullptr);

  QList<Operation *> operations() const;

  void addOperation(Operation *operation);
  void removeOperation(int index);
  void clearOperations();

  Q_INVOKABLE Operation *getOperation(int index) const;

private:
  QList<Operation *> _operations;
};
