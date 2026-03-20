import Foundation

enum TestFixtures {
    static let listJSON = Data(
        """
        {
          "plp": {
            "pagination": {
              "totalItems": 15451,
              "currentSet": 1,
              "viewSize": 48,
              "nextPage": {
                "href": "/women/clothing?fh_start_index=48"
              }
            },
            "styleColors": [
              {
                "styleColorId": "219370859_27",
                "slug": "shop-racil-lee-fringed-kaftan-for-women-219370859_27",
                "designerCategoryName": "Racil",
                "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=350,of=webp)/pub/media/catalog/product/2/1/219370859_yellow_in.jpg",
                "hoverImage": "//ounass-ae.atgcdn.ae/small_light(dw=350,of=webp)/pub/media/catalog/product/2/1/219370859_yellow_fr.jpg",
                "name": "Lee Fringed Kaftan",
                "price": 3700
              },
              {
                "styleColorId": "219466751_191",
                "slug": "shop-the-giving-movement-abaya-in-modal-for-women-219466751_191",
                "designerCategoryName": "The Giving Movement",
                "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=350,of=webp)/pub/media/catalog/product/2/1/219466751_offwhite_in.jpg",
                "hoverImage": "//ounass-ae.atgcdn.ae/small_light(dw=350,of=webp)/pub/media/catalog/product/2/1/219466751_offwhite_fr.jpg",
                "name": "Abaya in Modal",
                "price": 600
              }
            ],
            "noFilterUrl": "/women/clothing"
          }
        }
        """.utf8
    )

    static let detailJSON = Data(
        """
        {
          "pdp": {
            "styleColorId": "219370859_27",
            "slug": "shop-racil-lee-fringed-kaftan-for-women-219370859_27",
            "visibleSku": "219370882",
            "name": "Lee Fringed Kaftan",
            "designerCategoryName": "Racil",
            "price": 3700,
            "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/219370859_yellow_in.jpg",
            "media": [
              { "src": "/2/1/219370859_yellow_in.jpg" },
              { "src": "/2/1/219370859_yellow_fr.jpg" }
            ],
            "amberPoints": 3523,
            "shouldShowSwatchOptions": true,
            "descriptionText": "Fringe detailing brings movement and texture.",
            "colors": [
              {
                "styleColorId": "219370859_27",
                "url": "/shop-racil-lee-fringed-kaftan-for-women-219370859_27.html",
                "label": "Yellow",
                "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/219370859_yellow_in.jpg",
                "hex": "#FEE877",
                "isInStock": true
              },
              {
                "styleColorId": "219370859_14",
                "url": "/shop-racil-lee-fringed-kaftan-for-women-219370859_14.html",
                "label": "Blue",
                "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/219370859_blue_in.jpg",
                "hex": "#5E96E1",
                "isInStock": true
              }
            ],
            "selectedColor": {
              "styleColorId": "219370859_27",
              "url": "/shop-racil-lee-fringed-kaftan-for-women-219370859_27.html",
              "label": "Yellow",
              "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/219370859_yellow_in.jpg",
              "hex": "#FEE877",
              "isInStock": true
            },
            "sizes": [
              { "sku": "219370871", "sizeCodeId": 72, "sizeCode": "XS", "price": 3700, "amberPoints": 3523, "disabled": false, "stock": 1 },
              { "sku": "219370882", "sizeCodeId": 75, "sizeCode": "M", "price": 3700, "amberPoints": 3523, "disabled": false, "stock": 1 },
              { "sku": "219370910", "sizeCodeId": 74, "sizeCode": "S", "price": 3700, "amberPoints": 3523, "disabled": true, "stock": 0 }
            ],
            "outOfStock": false
          }
        }
        """.utf8
    )

    static let textColorDetailJSON = Data(
        """
        {
          "pdp": {
            "styleColorId": "218694515_16162",
            "slug": "shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_16162",
            "visibleSku": "219166438",
            "name": "Smooth Lounge Scoop Neck Maxi Dress",
            "designerCategoryName": "SKIMS",
            "price": 450,
            "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/218694515_henna_in.jpg?ts=1772786027.4972",
            "media": [
              { "src": "/2/1/218694515_henna_in.jpg?ts=1772786027.4972" },
              { "src": "/2/1/218694515_henna_fr.jpg?ts=1772786027.4972" }
            ],
            "amberPoints": 428,
            "shouldShowSwatchOptions": false,
            "descriptionText": "SKIMS' dress is a fan favourite for a reason.",
            "colors": [
              {
                "styleColorId": "218694515_16162",
                "url": "/shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_16162.html",
                "label": "Henna",
                "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/218694515_henna_in.jpg?ts=1772786027.4972",
                "hex": "#68392C",
                "isInStock": true
              },
              {
                "styleColorId": "218694515_12393",
                "url": "/shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_12393.html",
                "label": "Raisin",
                "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/218694515_dpi_in.jpg?ts=1772786027.4972",
                "hex": "#524144",
                "isInStock": false
              },
              {
                "styleColorId": "218694515_11264",
                "url": "/shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_11264.html",
                "label": "Obsidian",
                "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/218694515_obsidian_in.jpg?ts=1772786027.4972",
                "hex": "#3B3A3C",
                "isInStock": true
              }
            ],
            "selectedColor": {
              "styleColorId": "218694515_16162",
              "url": "/shop-skims-smooth-lounge-scoop-neck-maxi-dress-for-women-218694515_16162.html",
              "label": "Henna",
              "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/218694515_henna_in.jpg?ts=1772786027.4972",
              "hex": "#68392C",
              "isInStock": true
            },
            "sizes": [
              { "sku": "219166417", "sizeCodeId": 73, "sizeCode": "XXS", "price": 450, "amberPoints": 428, "disabled": false, "stock": 4 },
              { "sku": "219166438", "sizeCodeId": 71, "sizeCode": "L", "price": 450, "amberPoints": 428, "disabled": false, "stock": 11 }
            ],
            "outOfStock": false
          }
        }
        """.utf8
    )

    static let minimalDetailJSON = Data(
        """
        {
          "pdp": {
            "styleColorId": "219466751_191",
            "slug": "shop-the-giving-movement-abaya-in-modal-for-women-219466751_191",
            "visibleSku": "219466751",
            "name": "Abaya in Modal",
            "designerCategoryName": "The Giving Movement",
            "price": 600,
            "thumbnail": "//ounass-ae.atgcdn.ae/small_light(dw=240,of=webp)/pub/media/catalog/product/2/1/219466751_offwhite_in.jpg",
            "outOfStock": false
          }
        }
        """.utf8
    )
}
