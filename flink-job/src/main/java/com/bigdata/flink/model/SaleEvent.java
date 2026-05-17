package com.bigdata.flink.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import java.io.Serializable;

@JsonIgnoreProperties(ignoreUnknown = true)
public class SaleEvent implements Serializable {
    @JsonProperty("id") private String id;
    @JsonProperty("sale_customer_id") private Integer saleCustomerId;
    @JsonProperty("sale_seller_id") private Integer saleSellerId;
    @JsonProperty("sale_product_id") private Integer saleProductId;
    @JsonProperty("sale_date") private String saleDate;
    @JsonProperty("sale_quantity") private Integer saleQuantity;
    @JsonProperty("sale_total_price") private Double saleTotalPrice;
    @JsonProperty("customer_first_name") private String customerFirstName;
    @JsonProperty("customer_last_name") private String customerLastName;
    @JsonProperty("customer_age") private Integer customerAge;
    @JsonProperty("customer_email") private String customerEmail;
    @JsonProperty("customer_country") private String customerCountry;
    @JsonProperty("customer_postal_code") private String customerPostalCode;
    @JsonProperty("customer_pet_type") private String customerPetType;
    @JsonProperty("customer_pet_name") private String customerPetName;
    @JsonProperty("customer_pet_breed") private String customerPetBreed;
    @JsonProperty("seller_first_name") private String sellerFirstName;
    @JsonProperty("seller_last_name") private String sellerLastName;
    @JsonProperty("seller_email") private String sellerEmail;
    @JsonProperty("seller_country") private String sellerCountry;
    @JsonProperty("seller_postal_code") private String sellerPostalCode;
    @JsonProperty("product_name") private String productName;
    @JsonProperty("product_category") private String productCategory;
    @JsonProperty("product_price") private Double productPrice;
    @JsonProperty("product_quantity") private Integer productQuantity;
    @JsonProperty("product_brand") private String productBrand;
    @JsonProperty("product_size") private String productSize;
    @JsonProperty("product_material") private String productMaterial;
    @JsonProperty("product_color") private String productColor;
    @JsonProperty("product_weight") private Double productWeight;
    @JsonProperty("pet_category") private String petCategory;
    @JsonProperty("product_rating") private Double productRating;
    @JsonProperty("product_reviews") private Integer productReviews;
    @JsonProperty("product_release_date") private String productReleaseDate;
    @JsonProperty("product_expiry_date") private String productExpiryDate;

    public String getId() { return id; }
    public Integer getSaleCustomerId() { return saleCustomerId; }
    public Integer getSaleSellerId() { return saleSellerId; }
    public Integer getSaleProductId() { return saleProductId; }
    public String getSaleDate() { return saleDate; }
    public Integer getSaleQuantity() { return saleQuantity; }
    public Double getSaleTotalPrice() { return saleTotalPrice; }
    public String getCustomerFirstName() { return customerFirstName; }
    public String getCustomerLastName() { return customerLastName; }
    public Integer getCustomerAge() { return customerAge; }
    public String getCustomerEmail() { return customerEmail; }
    public String getCustomerCountry() { return customerCountry; }
    public String getCustomerPostalCode() { return customerPostalCode; }
    public String getCustomerPetType() { return customerPetType; }
    public String getCustomerPetName() { return customerPetName; }
    public String getCustomerPetBreed() { return customerPetBreed; }
    public String getSellerFirstName() { return sellerFirstName; }
    public String getSellerLastName() { return sellerLastName; }
    public String getSellerEmail() { return sellerEmail; }
    public String getSellerCountry() { return sellerCountry; }
    public String getSellerPostalCode() { return sellerPostalCode; }
    public String getProductName() { return productName; }
    public String getProductCategory() { return productCategory; }
    public Double getProductPrice() { return productPrice; }
    public Integer getProductQuantity() { return productQuantity; }
    public String getProductBrand() { return productBrand; }
    public String getProductSize() { return productSize; }
    public String getProductMaterial() { return productMaterial; }
    public String getProductColor() { return productColor; }
    public Double getProductWeight() { return productWeight; }
    public String getPetCategory() { return petCategory; }
    public Double getProductRating() { return productRating; }
    public Integer getProductReviews() { return productReviews; }
    public String getProductReleaseDate() { return productReleaseDate; }
    public String getProductExpiryDate() { return productExpiryDate; }
}
