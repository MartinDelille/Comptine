#pragma once

#include "PropertyMacros.h"
#include <QDate>
#include <QObject>
#include <QString>

class Operation : public QObject {
  Q_OBJECT

  PROPERTY_RW_INTERNAL(QDate, date, {})
  PROPERTY_RW_INTERNAL(double, amount, 0.0)
  PROPERTY_RW_INTERNAL(QString, category, {})
  PROPERTY_RW_INTERNAL(QString, description, {})

public:
  explicit Operation(QObject *parent = nullptr);
  Operation(const QDate &date, double amount, const QString &category,
            const QString &description, QObject *parent = nullptr);
};
