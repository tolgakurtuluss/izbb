#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
require(shinyMobile)
require(leaflet)
require(leaflet.extras)
require(tidyverse)
require(jsonlite)
require(htmltools)
require(readxl)
require(geosphere)
require(DT)
require(lubridate)


# Define UI for application that draws a histogram
f7Page(
    tags$style('body{background-color:#4B96AD;}'),
    tags$head(tags$style(HTML(".selectize-input {height: 35px; width: 140px; font-size: 16px;}"))),
    tags$head(tags$style(HTML(".f7-action-button {height: 35px; width: 140px; font-size: 16px;}"))),
    title = "ISMU App",
    options = list(dark = FALSE,tapHold = TRUE, 
                   tapHoldDelay = 100, iosTouchRipple = FALSE),
    f7TabLayout(
        navbar = f7Navbar(
            title = "Izmir ShinyMobile Ulaşım App", 
            hairline = TRUE,
            shadow = TRUE, leftPanel = TRUE, rightPanel = FALSE
        ),
        
        f7Tabs(animated = TRUE,
               f7Tab(
                   tabName = "Anasayfa",
                   icon = icon("home"),active = TRUE,
                   f7Card(
                       fluidRow(
                           h3("Izmir ShinyMobile Ulaşım (ISMU) App'e Hoşgeldiniz."),
                           h4("ISMU App'i kullanarak size en yakın Metro, Tramvay, İzban, ESHOT, Bisim, Vapur, TCDD ve Taksi duraklarını keşfedebilirsiniz. Bu uygulama tamamen açık kaynak kodludur ve İzmir Büyükşehir Belediyesi Açık Veri Portalı ulaşım verilerini kullanmaktadır.")
                       )
                   ),
                   f7Card(
                       fluidRow(
                           img(src = "eshot-logo.png", width = "10%"),
                           img(src = "izban-logo.png", width = "4%"),
                           img(src = "metro-logo.png", width = "5%"),
                           img(src = "tram-logo.png", width = "5%"),
                           img(src = "bisim-logo.png", width = "5%"),
                           img(src = "vapur-logo.png", width = "6%"),
                           img(src = "taksi-logo.png", width = "3%"),
                           img(src = "tcdd-logo.png", width = "4%")
                       )
                   ),
                   f7Card(title="Konum bilgisi",
                          fluidRow(shinyMobile::f7Col(width = 2,verbatimTextOutput("geolocation"),verbatimTextOutput("lat"),
                                             verbatimTextOutput("long")))) 
               ),
               f7Tab(
                   tabName = "Etraftaki Duraklar",
                   icon = icon("route"),
                   f7Card(title = "Durak Haritası",
                          fluidRow(
                              leafletOutput("mylocmap", height = 350)
                          )
                   ),
                   f7Card(title="Durak Detayları",tags$script('
    $(document).ready(function () {
      navigator.geolocation.getCurrentPosition(onSuccess, onError);
  
      function onError (err) {
      Shiny.onInputChange("geolocation", false);
      }
    
    function onSuccess (position) {
        setTimeout(function () {
            var coords = position.coords;
            console.log(coords.latitude + ", " + coords.longitude);
            Shiny.onInputChange("geolocation", true);
            Shiny.onInputChange("lat", coords.latitude);
            Shiny.onInputChange("long", coords.longitude);
        }, 1100)
    }
    });'),dataTableOutput("view")))
    ),
    f7Panel(
        title = h4("ISMU App",style = "color:#111111"), 
        side = "left", 
        theme = "light",
        effect = "cover",
        tags$hr(),
        p(h3("Izmir ShinyMobile Ulaşım App (ISMU App) R programlama dilinde ShinyMobile kütüphanesi kullanılarak açık-kaynak kodlu olarak hazırlanmıştır.", style = "color:#111111"),
          tags$hr(),shinyMobile::f7Link(label = p("Veri Kaynağı: Izmir Açık Veri Portalı",style = "color:#111111"), href = "https://acikveri.bizizmir.com/tr/dataset/"),
          img(src = "avp-logo.png", width = "75%")),
        tags$hr(),
        p(h4("Bu site altında yer alan tüm materyaller CC BY 4.0 uluslararası lisansı ile İzmir Büyükşehir Belediyesi adına lisanslanmıştır.", style = "color:#111111"),
          img(src = "cc.png", width = "50%"),
          shinyMobile::f7Link(label = p("Lisans hakkında",style = "color:#111111"), href = "https://acikveri.bizizmir.com/tr/license"))
    )
))