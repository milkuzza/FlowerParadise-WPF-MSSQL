using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;

namespace FlowerParadise
{
    public sealed class User
    {
        public int Id { get; set; }
        public string Login { get; set; }
        public string FullName { get; set; }
        public string Role { get; set; }
        public string RoleName { get; set; }

        public bool IsStaff
        {
            get
            {
                return Role == "admin" || Role == "manager";
            }
        }

        public bool IsAdmin
        {
            get
            {
                return Role == "admin";
            }
        }
    }

    public sealed class Category
    {
        public int Id { get; set; }
        public string Name { get; set; }
    }

    public sealed class Product
    {
        public int Id { get; set; }
        public int CategoryId { get; set; }
        public string Name { get; set; }
        public string Category { get; set; }
        public string Subcategory { get; set; }
        public string Manufacturer { get; set; }
        public string Composition { get; set; }
        public string Description { get; set; }
        public string ImagePath { get; set; }
        public long BasePriceKopecks { get; set; }
        public int Available { get; set; }
        

        public decimal Price
        {
            get
            {
                return BasePriceKopecks / 100m;
            }
        }

        public string PriceText
        {
            get
            {
                return Price.ToString("N2", Ui.Russian) + " ₽";
            }
        }

        public string StockText { get { return Available > 0 ? Available + " шт." : "Нет в наличии"; } }
        public bool OutOfStock { get { return Available == 0; } }

        public System.Windows.Media.Imaging.BitmapImage Image
        {
            get
            {
                return Ui.Image(ImagePath);
            }
        }
    }

    public sealed class StockOption
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public string Size { get; set; }
        public string SizeLabel { get { return Pricing.SizeLabel(Size); } }
        public int Available { get; set; }

        public string Label
        {
            get
            {
                return SizeLabel + " — в наличии " + Available + " шт.";
            }
        }
    }

    public sealed class CartLine
    {
        public int StockId { get; set; }
        public int ProductId { get; set; }
        public string Name { get; set; }
        public string Manufacturer { get; set; }
        public string Size { get; set; }
        public string SizeLabel { get { return Pricing.SizeLabel(Size); } }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }

        public decimal Total
        {
            get
            {
                return Quantity * UnitPrice;
            }
        }
    }

    public sealed class Order
    {
        public int Id { get; set; }
        public DateTime Date { get; set; }
        public string Customer { get; set; }
        public decimal Total { get; set; }
    }

    public sealed class OrderLine
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string Manufacturer { get; set; }
        public string Size { get; set; }
        public string SizeLabel { get { return Pricing.SizeLabel(Size); } }
        public int Quantity { get; set; }
        public decimal UnitPrice { get; set; }

        public decimal Total
        {
            get
            {
                return Quantity * UnitPrice;
            }
        }
    }

    public static class Pricing
    {
        public static string SizeLabel(string size)
        {
            int length;
            return int.TryParse(size, out length) ? size + " см" : size;
        }

        public static int ParseQuantity(string text)
        {
            int value;
            if (!int.TryParse(text, NumberStyles.None, CultureInfo.InvariantCulture, out value) || value < 1 || value > 10000)
            {
                throw new InvalidOperationException("Введите целое количество от 1 до 10 000 шт.");
            }

            return value;
        }
    }
}
