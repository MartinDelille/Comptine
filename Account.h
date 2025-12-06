#pragma once

#include <QList>
#include <QObject>
#include <QString>

#include "Operation.h"
#include "PropertyMacros.h"

class Account : public QObject {
  Q_OBJECT
  PROPERTY_RW(QString, name, QString())
  PROPERTY_RO(int, operationCount)

public:
  explicit Account(QObject *parent = nullptr);
  explicit Account(const QString &name, QObject *parent = nullptr);

  QList<Operation *> operations() const;

  void addOperation(Operation *operation);
  void removeOperation(int index);
  bool removeOperation(Operation *operation);  // Remove by pointer, returns true if found
  void clearOperations();
  bool hasOperation(const QDate &date, double amount, const QString &description) const;

  Q_INVOKABLE Operation *getOperation(int index) const;

private:
  QList<Operation *> _operations;
};
