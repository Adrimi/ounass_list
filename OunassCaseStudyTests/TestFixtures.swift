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
