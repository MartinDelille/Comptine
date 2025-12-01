#pragma once

#include <QObject>
#include <QString>

#include "PropertyMacros.h"

class Category : public QObject {
  Q_OBJECT
  PROPERTY_RW_INTERNAL(QString, name, QString())
  PROPERTY_RW_INTERNAL(double, budgetLimit, 0.0)

public:
  explicit Category(QObject *parent = nullptr);
  Category(const QString &name, double budgetLimit, QObject *parent = nullptr);
};
