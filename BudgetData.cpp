#include "BudgetData.h"
#include <QDate>
#include <QDebug>
#include <QFile>
#include <QRegularExpression>
#include <QTextStream>

BudgetData::BudgetData(QObject *parent) : QObject(parent) {}

BudgetData::~BudgetData() {
  clear();
}

int BudgetData::accountCount() const {
  return m_accounts.size();
}

QList<Account *> BudgetData::accounts() const {
  return m_accounts;
}

Account *BudgetData::getAccount(int index) const {
  if (index >= 0 && index < m_accounts.size()) {
    return m_accounts[index];
  }
  return nullptr;
}

Account *BudgetData::getAccountByName(const QString &name) const {
  for (Account *account : m_accounts) {
    if (account->name() == name) {
      return account;
    }
  }
  return nullptr;
}

void BudgetData::addAccount(Account *account) {
  if (account) {
    account->setParent(this);
    m_accounts.append(account);
    emit accountsChanged();
  }
}

void BudgetData::removeAccount(int index) {
  if (index >= 0 && index < m_accounts.size()) {
    delete m_accounts.takeAt(index);
    emit accountsChanged();
  }
}

void BudgetData::clearAccounts() {
  qDeleteAll(m_accounts);
  m_accounts.clear();
  emit accountsChanged();
}

int BudgetData::categoryCount() const {
  return m_categories.size();
}

QList<Category *> BudgetData::categories() const {
  return m_categories;
}

Category *BudgetData::getCategory(int index) const {
  if (index >= 0 && index < m_categories.size()) {
    return m_categories[index];
  }
  return nullptr;
}

Category *BudgetData::getCategoryByName(const QString &name) const {
  for (Category *category : m_categories) {
    if (category->name() == name) {
      return category;
    }
  }
  return nullptr;
}

void BudgetData::addCategory(Category *category) {
  if (category) {
    category->setParent(this);
    m_categories.append(category);
    emit categoriesChanged();
  }
}

void BudgetData::removeCategory(int index) {
  if (index >= 0 && index < m_categories.size()) {
    delete m_categories.takeAt(index);
    emit categoriesChanged();
  }
}

void BudgetData::clearCategories() {
  qDeleteAll(m_categories);
  m_categories.clear();
  emit categoriesChanged();
}

void BudgetData::clear() {
  clearAccounts();
  clearCategories();
}

QString BudgetData::escapeYamlString(const QString &str) const {
  if (str.contains('\n') || str.contains('"') || str.contains(':') ||
      str.contains('#') || str.startsWith(' ') || str.endsWith(' ')) {
    QString escaped = str;
    escaped.replace("\\", "\\\\");
    escaped.replace("\"", "\\\"");
    escaped.replace("\n", "\\n");
    return "\"" + escaped + "\"";
  }
  return str;
}

QString BudgetData::unescapeYamlString(const QString &str) const {
  QString result = str.trimmed();
  if (result.startsWith('"') && result.endsWith('"')) {
    result = result.mid(1, result.length() - 2);
    result.replace("\\n", "\n");
    result.replace("\\\"", "\"");
    result.replace("\\\\", "\\");
  }
  return result;
}

bool BudgetData::saveToYaml(const QString &filePath) const {
  QFile file(filePath);
  if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
    qWarning() << "Failed to open file for writing:" << filePath;
    return false;
  }

  QTextStream out(&file);
  out.setEncoding(QStringConverter::Utf8);

  // Write categories
  out << "categories:\n";
  for (const Category *category : m_categories) {
    out << "  - name: " << escapeYamlString(category->name()) << "\n";
    out << "    budget_limit: " << category->budgetLimit() << "\n";
  }

  // Write accounts
  out << "\naccounts:\n";
  for (const Account *account : m_accounts) {
    out << "  - name: " << escapeYamlString(account->name()) << "\n";
    out << "    balance: " << account->balance() << "\n";
    out << "    operations:\n";
    for (const Operation *op : account->operations()) {
      out << "      - date: " << op->date() << "\n";
      out << "        amount: " << op->amount() << "\n";
      out << "        category: " << escapeYamlString(op->category()) << "\n";
      out << "        description: " << escapeYamlString(op->description())
          << "\n";
    }
  }

  file.close();
  qDebug() << "Budget data saved to:" << filePath;
  return true;
}

bool BudgetData::loadFromYaml(const QString &filePath) {
  QFile file(filePath);
  if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
    qWarning() << "Failed to open file for reading:" << filePath;
    return false;
  }

  clear();

  QTextStream in(&file);
  in.setEncoding(QStringConverter::Utf8);

  enum class Section { None, Categories, Accounts, Operations };
  Section currentSection = Section::None;

  Account *currentAccount = nullptr;
  Category *currentCategory = nullptr;
  Operation *currentOperation = nullptr;

  QRegularExpression keyValueRe("^(\\s*)([\\w_]+):\\s*(.*)$");

  while (!in.atEnd()) {
    QString line = in.readLine();

    // Skip empty lines and comments
    if (line.trimmed().isEmpty() || line.trimmed().startsWith('#')) {
      continue;
    }

    auto match = keyValueRe.match(line);
    if (!match.hasMatch()) {
      continue;
    }

    int indent = match.captured(1).length();
    QString key = match.captured(2);
    QString value = unescapeYamlString(match.captured(3));

    // Top-level sections
    if (indent == 0) {
      if (key == "categories") {
        currentSection = Section::Categories;
      } else if (key == "accounts") {
        currentSection = Section::Accounts;
      }
      continue;
    }

    // List items (indicated by "- key: value" pattern)
    bool isListItem = line.trimmed().startsWith('-');

    if (currentSection == Section::Categories) {
      if (isListItem && key == "name") {
        currentCategory = new Category(this);
        currentCategory->setName(value);
        m_categories.append(currentCategory);
      } else if (currentCategory && key == "budget_limit") {
        currentCategory->setBudgetLimit(value.toDouble());
      }
    } else if (currentSection == Section::Accounts) {
      if (indent == 2 && isListItem && key == "name") {
        currentAccount = new Account(this);
        currentAccount->setName(value);
        m_accounts.append(currentAccount);
        currentOperation = nullptr;
      } else if (currentAccount && indent == 4 && key == "balance") {
        currentAccount->setBalance(value.toDouble());
      } else if (currentAccount && indent == 4 && key == "operations") {
        currentSection = Section::Operations;
      }
    } else if (currentSection == Section::Operations && currentAccount) {
      if (indent == 6 && isListItem && key == "date") {
        currentOperation = new Operation(currentAccount);
        currentOperation->setDate(QDate::fromString(value, "yyyy-MM-dd"));
        currentAccount->addOperation(currentOperation);
      } else if (currentOperation) {
        if (key == "amount") {
          currentOperation->setAmount(value.toDouble());
        } else if (key == "category") {
          currentOperation->setCategory(value);
        } else if (key == "description") {
          currentOperation->setDescription(value);
        }
      }

      // Check if we're back to accounts section
      if (indent == 2 && isListItem) {
        currentSection = Section::Accounts;
        currentAccount = new Account(this);
        currentAccount->setName(value);
        m_accounts.append(currentAccount);
        currentOperation = nullptr;
      }
    }
  }

  file.close();
  emit accountsChanged();
  emit categoriesChanged();
  emit dataLoaded();
  qDebug() << "Budget data loaded from:" << filePath;
  qDebug() << "  Accounts:" << m_accounts.size();
  qDebug() << "  Categories:" << m_categories.size();

  return true;
}
