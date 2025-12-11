#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QString>

#include "PropertyMacros.h"

class Category : public QObject {
  Q_OBJECT
  QML_ELEMENT
  PROPERTY_RW(QString, name, QString())
  PROPERTY_RW(double, budgetLimit, 0.0)

public:
  explicit Category(QObject* parent = nullptr);
  Category(const QString& name, double budgetLimit, QObject* parent = nullptr);
};
