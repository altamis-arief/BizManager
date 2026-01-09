# 📦 BizManager  
Small Business Inventory & Sales Management Mobile App

---

## 👥 Group Members
| Name | Matric Number |
|-----|---------------|
| KHAIRUL ZAKWAN BIN AHMAD | 2217035 |
| MOHAMAD IRFAN FIRDAUS BIN moh BASRI | 2218453 |
| MUHAMMAD ALTAMIS ARIEF BIN MOHD ZAHRY | 2212857 |

---

## 📌 Project Title
BizManager: A Small Business Inventory & Sales Management Mobile Application

---

## 🧩 Introduction

Small businesses often struggle with managing inventory, tracking sales, and monitoring daily performance due to reliance on manual records or fragmented tools such as spreadsheets and notebooks. These traditional methods are prone to errors, data loss, and inefficiency, especially as business operations grow.

BizManager is a mobile application designed to help small business owners manage their inventory and sales efficiently using a simple and user-friendly interface. The application centralizes product records, stock levels, and sales transactions, allowing business owners to make informed decisions in real time.

The project is relevant as it supports digital transformation among micro and small enterprises, improves operational efficiency, and reduces dependency on manual record-keeping.

---

## 🎯 Objectives

The objectives of BizManager are to:
- Provide an easy-to-use mobile platform for inventory and sales management
- Help small business owners track stock levels accurately
- Record and analyze daily sales transactions
- Reduce human errors caused by manual bookkeeping
- Improve decision-making through sales summaries and reports

---

## 👤 Target Users

- Small business owners
- Micro-entrepreneurs
- Home-based business operators
- Retail shop owners (e.g., grocery stores, kiosks, clothing shops)
- Startup merchants with limited technical background

---

## ⚙️ Features and Functionalities

### 🧱 Core Modules
- User Authentication
  - Login and registration
- Product Management
  - Add, update, delete products
  - View product list with stock quantity
- Inventory Tracking
  - Automatic stock updates after sales
  - Low-stock alerts
- Sales Management
  - Record sales transactions
  - Generate daily and monthly sales summaries
- Dashboard
  - Overview of total products, sales, and revenue

### 🧩 UI Components
- Bottom navigation bar
- Product cards
- Forms for data input
- Sales summary charts
- Alert dialogs and notifications

---

## 🎨 Proposed UI Mock-up





Key Screens:
- Login / Register Screen
- Dashboard Screen
- Product List Screen
- Add / Edit Product Screen
- Sales Transaction Screen

---

## 🏗️ Architecture / Technical Design

### 📐 Application Architecture
BizManager follows a layered architecture:
- Presentation Layer: Flutter UI widgets
- Logic Layer: State management and business logic
- Data Layer: Firebase Firestore database

### 🔧 Technology Stack
- Frontend: :
- Backend & Database: :Firebase

### 🔁 State Management
- Provider
  - Simple and suitable for small-to-medium scale apps
  - Manages product state, inventory updates, and sales data

---

## 🗃️ Data Model

### 🔥 Firestore Structure

```text
users (collection)
 └── userId
     ├── name
     ├── email

products (collection)
 └── productId
     ├── name
     ├── price
     ├── stock
     ├── category

sales (collection)
 └── saleId
     ├── productId
     ├── quantity
     ├── totalPrice
     ├── date
