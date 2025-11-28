#pragma once

#include "Account.h"
#include "Category.h"
#include <QList>
#include <QObject>
#include <QString>

class BudgetData : public QObject {
  Q_OBJECT
  Q_PROPERTY(int accountCount READ accountCount NOTIFY accountsChanged)
  Q_PROPERTY(int categoryCount READ categoryCount NOTIFY categoriesChanged)

public:
  explicit BudgetData(QObject *parent = nullptr);
  ~BudgetData();

  // Account management
  int accountCount() const;
  QList<Account *> accounts() const;
  Q_INVOKABLE Account *getAccount(int index) const;
  Q_INVOKABLE Account *getAccountByName(const QString &name) const;
  void addAccount(Account *account);
  void removeAccount(int index);
  void clearAccounts();

  // Category management
  int categoryCount() const;
  QList<Category *> categories() const;
  Q_INVOKABLE Category *getCategory(int index) const;
  Q_INVOKABLE Category *getCategoryByName(const QString &name) const;
  void addCategory(Category *category);
  void removeCategory(int index);
  void clearCategories();

  // File operations
  Q_INVOKABLE bool loadFromYaml(const QString &filePath);
  Q_INVOKABLE bool saveToYaml(const QString &filePath) const;

  // Clear all data
  Q_INVOKABLE void clear();

signals:
  void accountsChanged();
  void categoriesChanged();
  void dataLoaded();
  void dataSaved();

private:
  QString escapeYamlString(const QString &str) const;
  QString unescapeYamlString(const QString &str) const;

  QList<Account *> m_accounts;
  QList<Category *> m_categories;
};
