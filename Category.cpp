#include "Category.h"

Category::Category(QObject *parent) : QObject(parent) {}

Category::Category(const QString &name, double budgetLimit, QObject *parent)
    : QObject(parent), _name(name), _budgetLimit(budgetLimit) {}
