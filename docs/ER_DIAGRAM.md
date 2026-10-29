# ER-диаграмма

```mermaid
erDiagram
    roles ||--o{ users : role_id
    users ||--o{ orders : customer_id
    categories ||--o{ products : category_id
    subcategories ||--o{ products : subcategory_id
    manufacturers ||--o{ products : manufacturer_id
    products ||--o{ stock_items : product_id
    sizes ||--o{ stock_items : size_id
    orders ||--|{ order_items : order_id
    stock_items ||--o{ order_items : stock_item_id
    roles {
        int role_id PK
        varchar code UK
        nvarchar name UK
    }
    users {
        int user_id PK
        nvarchar last_name
        nvarchar first_name
        nvarchar middle_name
        nvarchar login UK
        int role_id FK
    }
    categories {
        int category_id PK
        nvarchar name UK
    }
    subcategories {
        int subcategory_id PK
        nvarchar name UK
    }
    manufacturers {
        int manufacturer_id PK
        nvarchar name UK
    }
    products {
        int product_id PK
        int category_id FK
        int subcategory_id FK
        int manufacturer_id FK
        nvarchar name
        nvarchar image_path
        nvarchar description
        nvarchar composition
        bigint price_kopecks
    }
    sizes {
        int size_id PK
        nvarchar value UK
        int sort_order
    }
    stock_items {
        int stock_item_id PK
        int product_id FK
        int size_id FK
        int available_quantity
    }
    orders {
        int order_id PK
        date order_date
        int customer_id FK
    }
    order_items {
        int order_item_id PK
        int order_id FK
        int stock_item_id FK
        int quantity
        bigint unit_price_kopecks
    }
```

Составные уникальные ключи: products(name, manufacturer_id), stock_items(product_id, size_id), order_items(order_id, stock_item_id). Удаление заказа каскадно удаляет строки; возврат остатков выполняется приложением в той же транзакции. Наличие хотя бы одной строки заказа обеспечивает слой операций с данными.
