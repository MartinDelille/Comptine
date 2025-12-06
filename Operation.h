#pragma once

#include <QDate>
#include <QObject>
#include <QString>
#include "PropertyMacros.h"

class Operation : public QObject {
  Q_OBJECT

  PROPERTY_RW(QDate, date, {})
  PROPERTY_RW(double, amount, 0.0)
  PROPERTY_RW(QString, category, {})
  PROPERTY_RW(QString, description, {})

public:
  explicit Operation(QObject *parent = nullptr);
  Operation(const QDate &date, double amount, const QString &category,
            const QString &description, QObject *parent = nullptr);
};
