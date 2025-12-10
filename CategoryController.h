#pragma once

#include <QList>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QUndoStack>
#include <QVariant>
#include "Category.h"
#include "PropertyMacros.h"

class Account;
class BudgetData;

class CategoryController : public QObject {
  Q_OBJECT

  PROPERTY_RO(int, categoryCount)

public:
  explicit CategoryController(QObject *parent = nullptr);

  // Set references to other controllers
  void setBudgetData(BudgetData *budgetData);
  void setUndoStack(QUndoStack *undoStack);

  // Category accessors
  QList<Category *> categories() const;
  Q_INVOKABLE Category *getCategory(int index) const;
  Q_INVOKABLE Category *getCategoryByName(const QString &name) const;
  Q_INVOKABLE QStringList categoryNames() const;

  // Category management
  void addCategory(Category *category);
  void removeCategory(int index);
  void clearCategories();
  Category *takeCategoryByName(const QString &name);  // Remove without deleting

  // Category editing (undoable)
  Q_INVOKABLE void editCategory(const QString &originalName, const QString &newName, double newBudgetLimit);

  // Budget calculations (aggregates across all accounts)
  Q_INVOKABLE double spentInCategory(const QString &categoryName, int year, int month) const;
  Q_INVOKABLE QVariantList monthlyBudgetSummary(int year, int month) const;
  Q_INVOKABLE QVariantList operationsForCategory(const QString &categoryName, int year, int month) const;

private:
  QList<Category *> _categories;
  BudgetData *_budgetData = nullptr;
  QUndoStack *_undoStack = nullptr;
};
