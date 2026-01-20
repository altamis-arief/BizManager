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
<img width="385" height="860" alt="image" src="https://github.com/user-attachments/assets/6f4d39ca-2b3b-4929-8e94-058b9b574ca1" />

- Dashboard Screen
<img width="388" height="861" alt="image" src="https://github.com/user-attachments/assets/eac0d0fa-541c-4d74-bf38-c16f94b3111e" />

- Product List Screen
<img width="388" height="860" alt="image" src="https://github.com/user-attachments/assets/e613d670-6843-4f15-8235-866e551fcda8" />

- Add / Edit Product Screen
<img width="386" height="861" alt="image" src="https://github.com/user-attachments/assets/7a26a85d-2532-4b91-a391-b65219f8ef08" />

- Sales Transaction Screen
<img width="387" height="860" alt="image" src="https://github.com/user-attachments/assets/7689ff72-1e43-477a-b845-2556d7dde2c7" />


---

## 🏗️ Architecture / Technical Design

### 📐 Application Architecture
BizManager follows a layered architecture:
- Presentation Layer: Flutter UI widgets
- Logic Layer: State management and business logic
- Data Layer: Firebase Firestore database

### 🔧 Technology Stack
- Frontend: : Flutter Framework
- Backend & Database: :Firebase

### 🔁 State Management
- Provider
  - Simple and suitable for small-to-medium scale apps
  - Manages product state, inventory updates, and sales data


---
## Final User Interfaces

- Dashboard
<img width="388" height="860" alt="image" src="https://github.com/user-attachments/assets/9bc1357e-e914-472a-9d74-761b06136d00" />

- Product Management
<img width="386" height="862" alt="image" src="https://github.com/user-attachments/assets/b88c0638-113d-4392-9502-ba136d124507" />

- Point of Sale
<img width="384" height="862" alt="image" src="https://github.com/user-attachments/assets/57286e0f-b297-4f6b-a6dc-370bb2258860" />

- Inventory Tracking
<img width="386" height="862" alt="image" src="https://github.com/user-attachments/assets/dba9195d-d945-4cbd-8f40-55c950c5a1a8" />

- Sales Report 
<img width="387" height="859" alt="image" src="https://github.com/user-attachments/assets/c4b02dd4-febb-44b2-9e2a-dfb8acec8b8f" />

- Add Product 
<img width="387" height="861" alt="image" src="https://github.com/user-attachments/assets/d8fb2be8-4df3-49f8-ac87-8891d081e3d3" />

---
## Summary of Features

There are 4 main features that BizManager has achieved which are the Product management. This Feature can add,edit, delete and update its new product into the system. Next, Sales Tracking. It tracks according to how many products have been sold. Third feature is the
Inventory Tracking. This feature helps to track available stock. The user can monitor their stocks of products. Lastly, Sales report. It summarise the sales report based on how much sales does it produce by week,month or year.

---

## Technical Explanation

We have been using Firebase as our database. The products have been created will be stored in our Firebase database including the user accounts.

--- 

## Limitations and Future Enhancements

Limitations
- Not fully adapated into real business enviroment
- No intergration into a real business system

Future Enhancements
- Intergrated system with a real business enviroment
- AI intergration into system

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

---

