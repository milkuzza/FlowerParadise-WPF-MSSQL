IF DB_ID(N'FlowerParadise') IS NULL CREATE DATABASE [FlowerParadise] COLLATE Cyrillic_General_100_CI_AS;
GO
USE [FlowerParadise];
GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
CREATE TABLE dbo.roles (
    role_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_roles PRIMARY KEY,
    code varchar(20) NOT NULL CONSTRAINT UQ_roles_code UNIQUE,
    name nvarchar(80) NOT NULL CONSTRAINT UQ_roles_name UNIQUE,
    CONSTRAINT CK_roles_code CHECK(code IN ('admin','manager','customer'))
);
CREATE TABLE dbo.users (
    user_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_users PRIMARY KEY,
    last_name nvarchar(100) NOT NULL,
    first_name nvarchar(100) NOT NULL,
    middle_name nvarchar(100) NOT NULL,
    login nvarchar(100) NOT NULL CONSTRAINT UQ_users_login UNIQUE,
    role_id int NOT NULL,
    CONSTRAINT FK_users_roles FOREIGN KEY(role_id) REFERENCES dbo.roles(role_id)
);
CREATE TABLE dbo.categories (
    category_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_categories PRIMARY KEY,
    name nvarchar(100) NOT NULL CONSTRAINT UQ_categories_name UNIQUE
);
CREATE TABLE dbo.subcategories (
    subcategory_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_subcategories PRIMARY KEY,
    name nvarchar(100) NOT NULL CONSTRAINT UQ_subcategories_name UNIQUE
);
CREATE TABLE dbo.manufacturers (
    manufacturer_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_manufacturers PRIMARY KEY,
    name nvarchar(200) NOT NULL CONSTRAINT UQ_manufacturers_name UNIQUE
);
CREATE TABLE dbo.products (
    product_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_products PRIMARY KEY,
    category_id int NOT NULL,
    subcategory_id int NOT NULL,
    manufacturer_id int NOT NULL,
    name nvarchar(300) NOT NULL,
    image_path nvarchar(250) NULL,
    description nvarchar(max) NOT NULL,
    composition nvarchar(2000) NOT NULL,
    price_kopecks bigint NOT NULL,
    CONSTRAINT UQ_products_model UNIQUE(name,manufacturer_id),
    CONSTRAINT CK_products_price CHECK(price_kopecks BETWEEN 0 AND 100000000000),
    CONSTRAINT FK_products_categories FOREIGN KEY(category_id) REFERENCES dbo.categories(category_id),
    CONSTRAINT FK_products_subcategories FOREIGN KEY(subcategory_id) REFERENCES dbo.subcategories(subcategory_id),
    CONSTRAINT FK_products_manufacturers FOREIGN KEY(manufacturer_id) REFERENCES dbo.manufacturers(manufacturer_id)
);
CREATE TABLE dbo.sizes (
    size_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_sizes PRIMARY KEY,
    value nvarchar(10) NOT NULL CONSTRAINT UQ_sizes_value UNIQUE,
    sort_order int NOT NULL,
    CONSTRAINT CK_sizes_value CHECK(value IN (N'40',N'50',N'60',N'70',N'80',N'90',N'S',N'M',N'L',N'XL'))
);
CREATE TABLE dbo.stock_items (
    stock_item_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_stock_items PRIMARY KEY,
    product_id int NOT NULL,
    size_id int NOT NULL,
    available_quantity int NOT NULL,
    CONSTRAINT UQ_stock_items_variant UNIQUE(product_id,size_id),
    CONSTRAINT CK_stock_items_quantity CHECK(available_quantity BETWEEN 0 AND 1000000),
    CONSTRAINT FK_stock_items_products FOREIGN KEY(product_id) REFERENCES dbo.products(product_id),
    CONSTRAINT FK_stock_items_sizes FOREIGN KEY(size_id) REFERENCES dbo.sizes(size_id)
);
CREATE TABLE dbo.orders (
    order_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_orders PRIMARY KEY,
    order_date date NOT NULL,
    customer_id int NOT NULL,
    CONSTRAINT FK_orders_users FOREIGN KEY(customer_id) REFERENCES dbo.users(user_id)
);
CREATE TABLE dbo.order_items (
    order_item_id int IDENTITY(1,1) NOT NULL CONSTRAINT PK_order_items PRIMARY KEY,
    order_id int NOT NULL,
    stock_item_id int NOT NULL,
    quantity int NOT NULL,
    unit_price_kopecks bigint NOT NULL,
    CONSTRAINT UQ_order_items_variant UNIQUE(order_id,stock_item_id),
    CONSTRAINT CK_order_items_quantity CHECK(quantity BETWEEN 1 AND 10000),
    CONSTRAINT CK_order_items_price CHECK(unit_price_kopecks BETWEEN 0 AND 100000000000),
    CONSTRAINT FK_order_items_orders FOREIGN KEY(order_id) REFERENCES dbo.orders(order_id) ON DELETE CASCADE,
    CONSTRAINT FK_order_items_stock_items FOREIGN KEY(stock_item_id) REFERENCES dbo.stock_items(stock_item_id)
);
CREATE INDEX IX_orders_date ON dbo.orders(order_date,order_id);
CREATE INDEX IX_orders_customer ON dbo.orders(customer_id);
CREATE INDEX IX_order_items_stock ON dbo.order_items(stock_item_id,order_id);
COMMIT TRANSACTION;
GO
CREATE VIEW dbo.order_totals AS
SELECT o.order_id,o.order_date,o.customer_id,
    COALESCE(SUM(CAST(oi.quantity AS bigint)*oi.unit_price_kopecks),0) AS total_kopecks
FROM dbo.orders o LEFT JOIN dbo.order_items oi ON oi.order_id=o.order_id
GROUP BY o.order_id,o.order_date,o.customer_id;
GO

GO
SET XACT_ABORT ON;
BEGIN TRANSACTION;
SET IDENTITY_INSERT dbo.roles ON;
INSERT dbo.roles (role_id,code,name) VALUES
(1,N'admin',N'Администратор'),
(2,N'manager',N'Менеджер'),
(3,N'customer',N'Авторизованный пользователь');
SET IDENTITY_INSERT dbo.roles OFF;
SET IDENTITY_INSERT dbo.users ON;
INSERT dbo.users (user_id,last_name,first_name,middle_name,login,role_id) VALUES
(1,N'Орлов',N'Максим',N'Андреевич',N'morlov',1),
(2,N'Белова',N'Ксения',N'Игоревна',N'kbelova',2),
(3,N'Морозова',N'Дарья',N'Сергеевна',N'dmorozova',3),
(4,N'Волков',N'Артём',N'Павлович',N'avolkov',2),
(5,N'Соколова',N'Марина',N'Олеговна',N'msokolova',3),
(6,N'Лебедев',N'Кирилл',N'Денисович',N'klebedev',1),
(7,N'Козлова',N'Полина',N'Андреевна',N'pkozlova',3),
(8,N'Новиков',N'Егор',N'Викторович',N'enovikov',2),
(9,N'Зайцева',N'Алина',N'Романовна',N'azaitseva',3),
(10,N'Павлов',N'Никита',N'Сергеевич',N'npavlov',2),
(11,N'Семёнова',N'Вероника',N'Алексеевна',N'vsemenova',3),
(12,N'Голубев',N'Роман',N'Ильич',N'rgolubev',1),
(13,N'Виноградова',N'Софья',N'Михайловна',N'svinogradova',3),
(14,N'Богданов',N'Илья',N'Константинович',N'ibogdanov',2),
(15,N'Фёдорова',N'Ульяна',N'Дмитриевна',N'ufedorova',3),
(16,N'Михайлов',N'Глеб',N'Николаевич',N'gmikhailov',2),
(17,N'Ершова',N'Таисия',N'Валерьевна',N'tershova',3),
(18,N'Тарасов',N'Лев',N'Андреевич',N'ltarasov',1),
(19,N'Ковалёва',N'Милана',N'Евгеньевна',N'mkovaleva',3),
(20,N'Никитин',N'Тимур',N'Олегович',N'tnikitin',2);
SET IDENTITY_INSERT dbo.users OFF;
SET IDENTITY_INSERT dbo.categories ON;
INSERT dbo.categories (category_id,name) VALUES
(1,N'Срезанные цветы'),
(2,N'Букеты'),
(3,N'Композиции');
SET IDENTITY_INSERT dbo.categories OFF;
SET IDENTITY_INSERT dbo.subcategories ON;
INSERT dbo.subcategories (subcategory_id,name) VALUES
(1,N'Розы'),
(2,N'Тюльпаны'),
(3,N'Пионы'),
(4,N'Хризантемы'),
(5,N'Гортензии'),
(6,N'Лилии');
SET IDENTITY_INSERT dbo.subcategories OFF;
SET IDENTITY_INSERT dbo.manufacturers ON;
INSERT dbo.manufacturers (manufacturer_id,name) VALUES
(1,N'Розовая долина'),
(2,N'Флора Юг'),
(3,N'Тюльпания'),
(4,N'Подмосковные теплицы'),
(5,N'Пионовый край'),
(6,N'Хризантема-Агро'),
(7,N'Гортензия Плюс'),
(8,N'Лилейник'),
(9,N'Букетная фабрика'),
(10,N'Северный сад'),
(11,N'Солнечные теплицы'),
(12,N'Белый лотос'),
(13,N'Луговые травы'),
(14,N'Цветочный двор'),
(15,N'Зелёная линия'),
(16,N'Садовая мастерская');
SET IDENTITY_INSERT dbo.manufacturers OFF;
SET IDENTITY_INSERT dbo.products ON;
INSERT dbo.products (product_id,category_id,subcategory_id,manufacturer_id,name,image_path,description,composition,price_kopecks) VALUES
(1,1,1,1,N'Роза «Фридом» красная',N'Images/IMG_CR_101501.png',N'Классическая красная роза с крупным бутоном, стойкость в вазе до 12 дней. Поставщик: ООО «Розовая долина», г. Краснодар',N'Роза Freedom — 1 шт.',19000),
(2,1,1,1,N'Роза «Аваланж» белая',N'Images/IMG_CR_101507.png',N'Белая роза с плотным бутоном, подходит для свадебных букетов. Поставщик: ООО «Розовая долина», г. Краснодар',N'Роза Avalanche — 1 шт.',21000),
(3,1,1,2,N'Роза кустовая «Леди Бомбастик»',N'Images/IMG_CR_101512.png',N'Кустовая роза с 5–7 пионовидными бутонами нежно-розового цвета. Поставщик: ООО «Флора Юг», г. Сочи',N'Роза кустовая Lady Bombastic — 1 ветка',25000),
(4,1,2,3,N'Тюльпан «Стронг Голд» жёлтый',N'Images/IMG_CT_102204.png',N'Яркий жёлтый тюльпан, срезан в стадии плотного бутона. Поставщик: Тепличный комплекс «Тюльпания», г. Калуга',N'Тюльпан Strong Gold — 1 шт.',12000),
(5,1,2,4,N'Тюльпан «Пинк Импрешн» розовый',N'Images/IMG_CT_102209.png',N'Крупный розовый тюльпан на высоком прочном стебле. Поставщик: АО «Подмосковные теплицы», г. Дмитров',N'Тюльпан Pink Impression — 1 шт.',13000),
(6,1,2,3,N'Тюльпаны микс',N'Images/IMG_CT_102215.png',N'Тюльпаны разных сортов и цветов, подбор цвета флористом. Поставщик: Тепличный комплекс «Тюльпания», г. Калуга',N'Тюльпан, сорта в ассортименте — 1 шт.',11000),
(7,1,2,4,N'Тюльпаны микс',NULL,N'Тюльпаны разных сортов и цветов, подбор цвета флористом. Поставщик: АО «Подмосковные теплицы», г. Дмитров',N'Тюльпан, сорта в ассортименте — 1 шт.',11500),
(8,1,3,5,N'Пион «Сара Бернар»',N'Images/IMG_CP_103301.png',N'Махровый пион светло-розового цвета с ароматом. Поставщик: КФХ «Пионовый край», г. Ставрополь',N'Пион Sarah Bernhardt — 1 шт.',45000),
(9,1,3,5,N'Пион «Корал Шарм»',N'Images/IMG_CP_103306.png',N'Полумахровый пион кораллового цвета, сезонный сорт. Поставщик: КФХ «Пионовый край», г. Ставрополь',N'Пион Coral Charm — 1 шт.',52000),
(10,1,4,6,N'Хризантема кустовая «Бакарди»',N'Images/IMG_CH_104402.png',N'Кустовая ромашковидная хризантема, стойкость до 3 недель. Поставщик: ООО «Хризантема-Агро», г. Ростов-на-Дону',N'Хризантема кустовая Bacardi — 1 ветка',28000),
(11,1,4,6,N'Хризантема одноголовая «Антонов»',N'Images/IMG_CH_104408.png',N'Крупная одноголовая хризантема белого цвета. Поставщик: ООО «Хризантема-Агро», г. Ростов-на-Дону',N'Хризантема Antonov — 1 шт.',32000),
(12,1,5,7,N'Гортензия голубая',N'Images/IMG_CG_105501.png',N'Пышное соцветие голубой гортензии, поставляется в колбе с водой. Поставщик: ИП Малинина О.В. (бренд «Гортензия Плюс»), г. Воронеж',N'Гортензия крупнолистная — 1 шт., колба с водой',69000),
(13,1,6,8,N'Лилия «Сибирь» белая',N'Images/IMG_CL_106601.png',N'Восточная лилия с крупными белыми цветками и сильным ароматом. Поставщик: ООО «Лилейник», г. Казань',N'Лилия Siberia — 1 ветка (3–5 бутонов)',39000),
(14,1,6,8,N'Лилия «Тигровая»',N'Images/IMG_CL_106605.png',N'Оранжевая лилия с тёмными крапинками, без запаха. Поставщик: ООО «Лилейник», г. Казань',N'Лилия тигровая — 1 ветка (4–6 бутонов)',41000),
(15,2,1,9,N'Букет «Классика» из красных роз',N'Images/IMG_BR_201101.png',N'Букет из красных роз в дизайнерской упаковке. Поставщик: ООО «Букетная фабрика», г. Москва',N'Роза Freedom 60 см — от 9 до 51 шт. (по размеру), упаковка — плёнка матовая, лента атласная',349000),
(16,2,3,5,N'Букет «Нежность» из пионов',N'Images/IMG_BP_201305.png',N'Воздушный букет из розовых пионов с зеленью. Поставщик: КФХ «Пионовый край», г. Ставрополь',N'Пион Sarah Bernhardt — 7/11/15 шт., эвкалипт — 3 ветки, упаковка — крафт',690000),
(17,2,2,3,N'Букет «Весеннее утро» из тюльпанов',N'Images/IMG_BT_201208.png',N'Букет из разноцветных тюльпанов, перевязан лентой. Поставщик: Тепличный комплекс «Тюльпания», г. Калуга',N'Тюльпан микс — 15/25/35 шт., лента атласная, упаковка — бумага тишью',249000),
(18,2,4,10,N'Букет «Северное сияние» из хризантем',N'Images/IMG_BH_201402.png',N'Яркий стойкий букет из кустовых хризантем. Поставщик: Компания «Северный сад», г. Вологда',N'Хризантема кустовая — 5/9 веток, писташ — 3 ветки, упаковка — крафт',289000),
(19,2,5,7,N'Букет «Облако» из гортензий',N'Images/IMG_BG_201501.png',N'Пышный букет из белых и голубых гортензий. Поставщик: ИП Малинина О.В. (бренд «Гортензия Плюс»), г. Воронеж',N'Гортензия крупнолистная — 3/5 шт., эвкалипт — 2 ветки, упаковка — фетр',549000),
(20,2,6,8,N'Букет «Королевская лилия»',N'Images/IMG_BL_201603.png',N'Торжественный букет из белых лилий с зеленью. Поставщик: ООО «Лилейник», г. Казань',N'Лилия Siberia — 5/7/9 веток, рускус — 5 веток, упаковка — плёнка',459000),
(21,2,1,11,N'Букет «Солнечный» из кустовых роз',N'Images/IMG_BR_201110.png',N'Яркий букет из жёлтых и оранжевых кустовых роз. Поставщик: АО «Солнечные теплицы», г. Белгород',N'Роза кустовая — 7/11 веток, упаковка — крафт, лента джутовая',299000),
(22,2,1,12,N'Букет «Белый танец» из роз',N'Images/IMG_BR_201115.png',N'Букет из белых роз и эвкалипта для торжественных событий. Поставщик: Флористическая студия «Белый лотос», г. Самара',N'Роза Avalanche — 15/25/35 шт., эвкалипт — 5 веток, упаковка — плёнка',499000),
(23,2,4,13,N'Букет «Луговой» с хризантемами',N'Images/IMG_BH_201409.png',N'Букет в полевом стиле с ромашковидными хризантемами и травами. Поставщик: КФХ «Луговые травы», г. Ярославль',N'Хризантема кустовая — 5/7 веток, лимониум — 3 ветки, упаковка — крафт',199000),
(24,3,1,14,N'Композиция «Шляпная коробка» с розами',N'Images/IMG_KR_301104.png',N'Розы в круглой шляпной коробке на флористической губке. Поставщик: Мастерская «Цветочный двор», г. Тула',N'Роза кустовая — 11/19/29 шт., коробка шляпная, губка флористическая',599000),
(25,3,2,15,N'Композиция «Ящик тюльпанов»',N'Images/IMG_KT_301206.png',N'Тюльпаны в деревянном ящике с мхом. Поставщик: ООО «Зелёная линия», г. Рязань',N'Тюльпан микс — 25/41 шт., ящик деревянный, мох декоративный',429000),
(26,3,3,16,N'Композиция «Пионовая корзина»',N'Images/IMG_KP_301302.png',N'Пионы с зеленью в плетёной корзине. Поставщик: ИП Ершов А.Н. (бренд «Садовая мастерская»), г. Тверь',N'Пион Sarah Bernhardt — 11/19 шт., салал — 5 веток, корзина плетёная',899000),
(27,3,5,16,N'Композиция «Гортензия в кашпо»',N'Images/IMG_KG_301507.png',N'Живая гортензия в керамическом кашпо. Поставщик: ИП Ершов А.Н. (бренд «Садовая мастерская»), г. Тверь',N'Гортензия в горшке — 1 шт., кашпо керамическое',399000),
(28,3,6,14,N'Композиция «Лилии в корзине»',N'Images/IMG_KL_301601.png',N'Лилии с хризантемами и зеленью в корзине. Поставщик: Мастерская «Цветочный двор», г. Тула',N'Лилия Siberia — 5/7 веток, хризантема кустовая — 3 ветки, корзина',649000),
(29,3,4,15,N'Композиция «Осенняя» с хризантемами',N'Images/IMG_KH_301403.png',N'Тёплая осенняя композиция в деревянном ящике. Поставщик: ООО «Зелёная линия», г. Рязань',N'Хризантема кустовая — 5/7/9 веток, ягоды гиперикума — 3 ветки, ящик деревянный',329000),
(30,3,1,12,N'Композиция «Сердце» из роз',N'Images/IMG_KR_301120.png',N'Красные розы в коробке в форме сердца. Поставщик: Флористическая студия «Белый лотос», г. Самара',N'Роза Freedom — 51/101 шт., коробка «сердце», губка флористическая',999000),
(31,3,4,10,N'Композиция «Мини-сад» с хризантемами',NULL,N'Небольшая композиция в кашпо для подарка коллегам. Поставщик: Компания «Северный сад», г. Вологда',N'Хризантема кустовая — 3 ветки, кашпо пластиковое',179000);
SET IDENTITY_INSERT dbo.products OFF;
SET IDENTITY_INSERT dbo.sizes ON;
INSERT dbo.sizes (size_id,value,sort_order) VALUES
(1,N'40',1),
(2,N'50',2),
(3,N'60',3),
(4,N'70',4),
(5,N'80',5),
(6,N'90',6),
(7,N'S',7),
(8,N'M',8),
(9,N'L',9),
(10,N'XL',10);
SET IDENTITY_INSERT dbo.sizes OFF;
SET IDENTITY_INSERT dbo.stock_items ON;
INSERT dbo.stock_items (stock_item_id,product_id,size_id,available_quantity) VALUES
(1,1,1,120),
(2,1,2,150),
(3,1,3,90),
(4,1,4,40),
(5,2,2,60),
(6,2,3,80),
(7,2,4,30),
(8,2,5,10),
(9,3,1,35),
(10,3,2,20),
(11,4,1,200),
(12,4,2,100),
(13,5,1,0),
(14,5,2,70),
(15,6,1,280),
(16,7,1,150),
(17,7,2,80),
(18,8,2,25),
(19,8,3,15),
(20,9,2,0),
(21,9,3,0),
(22,10,3,45),
(23,10,4,30),
(24,11,4,20),
(25,11,5,12),
(26,12,2,18),
(27,12,3,6),
(28,13,4,25),
(29,13,5,15),
(30,13,6,5),
(31,14,4,10),
(32,14,5,0),
(33,15,7,8),
(34,15,8,10),
(35,15,9,6),
(36,15,10,2),
(37,16,7,3),
(38,16,8,2),
(39,16,9,1),
(40,17,7,12),
(41,17,8,9),
(42,17,9,4),
(43,18,8,7),
(44,18,9,3),
(45,19,8,4),
(46,19,9,2),
(47,20,8,5),
(48,20,9,3),
(49,20,10,0),
(50,21,7,6),
(51,21,8,4),
(52,22,8,4),
(53,22,9,3),
(54,22,10,1),
(55,23,7,0),
(56,23,8,0),
(57,24,7,5),
(58,24,8,4),
(59,24,9,2),
(60,25,8,6),
(61,25,9,0),
(62,26,8,2),
(63,26,9,1),
(64,27,7,7),
(65,27,8,3),
(66,28,8,3),
(67,28,9,2),
(68,29,7,9),
(69,29,8,6),
(70,29,9,2),
(71,30,9,2),
(72,30,10,1),
(73,31,7,15);
SET IDENTITY_INSERT dbo.stock_items OFF;
SET IDENTITY_INSERT dbo.orders ON;
INSERT dbo.orders (order_id,order_date,customer_id) VALUES
(1,N'2026-04-02',3),
(2,N'2026-04-05',5),
(3,N'2026-04-08',7),
(4,N'2026-04-12',9),
(5,N'2026-04-15',11),
(6,N'2026-04-19',13),
(7,N'2026-04-23',15),
(8,N'2026-04-27',17),
(9,N'2026-05-01',19),
(10,N'2026-05-06',3);
SET IDENTITY_INSERT dbo.orders OFF;
SET IDENTITY_INSERT dbo.order_items ON;
INSERT dbo.order_items (order_item_id,order_id,stock_item_id,quantity,unit_price_kopecks) VALUES
(1,1,34,1,349000),
(2,1,11,5,12000),
(3,2,37,1,690000),
(4,2,62,1,899000),
(5,2,26,1,69000),
(6,3,3,15,19000),
(7,3,6,10,21000),
(8,3,52,1,499000),
(9,4,42,1,249000),
(10,4,57,1,599000),
(11,4,28,3,39000),
(12,4,64,1,399000),
(13,5,71,1,999000),
(14,5,45,1,549000),
(15,5,22,5,28000),
(16,6,15,25,11000),
(17,6,69,1,329000),
(18,7,43,1,289000),
(19,7,9,7,25000),
(20,7,60,1,429000),
(21,8,18,9,45000),
(22,8,50,1,299000),
(23,8,67,1,649000),
(24,9,17,11,11500),
(25,9,48,1,459000),
(26,9,31,3,41000),
(27,9,73,2,179000),
(28,10,54,1,499000),
(29,10,24,5,32000),
(30,10,14,15,13000),
(31,10,38,1,690000);
SET IDENTITY_INSERT dbo.order_items OFF;
EXEC sys.sp_addextendedproperty @name=N'FlowerParadise.SchemaVersion', @value=N'1';
COMMIT TRANSACTION;