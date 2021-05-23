#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
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


# Define server logic required to draw a histogram
function(input, output, session){
    
    output$lat <- renderText({
        paste("Enlem:", input$lat)
    })
    
    output$long <- renderText({
        paste("Boylam:", input$long)
    })
    
    output$geolocation <- renderText({
        paste("Konuma Erişim :", input$geolocation)
    }) 
    
    locdata <- reactive({
        data.frame(lat=as.numeric(input$lat), long=as.numeric(input$long))
    })
    
    tr <- as.data.frame(read_excel("ab.xlsx"))
    
    newData <- reactive({
        shiny::validate(
            shiny::need(input$geolocation == TRUE, 'Lutfen konum erisimine izin veriniz ve sayfayı yenileyiniz.')
        )
        tr %>%
            rename("DurakAdi"="Adi") %>% 
            mutate(MetreMesafe = round(distHaversine(data.frame(Boylam, Enlem),c(input$long, input$lat)),0),
                   YuruyusRotası = paste0('<img src="osmlogo.png" height="20"></img>',"<a href='","https://www.openstreetmap.org/directions?engine=fossgis_osrm_foot&route=",input$lat,"%2C",input$long,"%3B",Enlem,"%2C",Boylam,"#map=14/",input$lat,"/",input$long,"'>","RotaOlustur","</a>"),
                   DurakTuru= ifelse(type %in% "tramvay",'<img src="tram-logo.png" height="35"></img>',ifelse(type %in% "metro",'<img src="metro-logo.png" height="35"></img>',ifelse(type %in% "otobusdurak",'<img src="eshot-logo2.png" height="40"></img>',ifelse(type %in% "izban",'<img src="izban-logo.png" height="40"></img>',ifelse(type %in% "bisim",'<img src="bisim-logo.png" height="40"></img>',ifelse(type %in% "vapur",'<img src="vapur-logo.png" height="35"></img>',ifelse(type %in% "taksi",'<img src="taksi-logo.png" height="33"></img>','<img src="tcdd-logo.png" height="35"></img>')))))))) %>%
            arrange(MetreMesafe) %>% select(DurakAdi,type,DurakId,MetreMesafe,Boylam,Enlem,GecenHatNumaralari,YuruyusRotası,DurakTuru) %>% head(20)
    })
    

    
    output$mylocmap <- renderLeaflet({
        leaflet() %>% 
            addTiles() %>%
            setView(input$long, input$lat, zoom = 16) %>% 
            addPulseMarkers(lng = locdata()$long, lat = locdata()$lat, label = "Guncel Konumum", icon = makePulseIcon(heartbeat = 0.5))%>%
            addMarkers(lng=newData()$Boylam, lat=newData()$Enlem, popup=ifelse(newData()$type %in% "otobusdurak",paste0(newData()$DurakAdi," Duragı","</br>","Duraktan Gecen Hatlar: ",newData()$GecenHatNumaralari),paste0(newData()$DurakAdi," Duragı")), icon = makeIcon(
                iconUrl = ifelse(newData()$type %in% "tramvay","tram-logo.png",ifelse(newData()$type %in% "metro","metro-logo.png",ifelse(newData()$type %in% "otobusdurak","eshot-logo2.png",ifelse(newData()$type %in% "izban","izban-logo.png",ifelse(newData()$type %in% "bisim","bisim-logo.png",ifelse(newData()$type %in% "vapur","vapur-logo.png",ifelse(newData()$type %in% "taksi","taksi-logo.png","tcdd-logo.png"))))))),
                iconWidth = 30, iconHeight = 30
            )) %>% addFullscreenControl()
    })
    
    output$view = DT::renderDataTable(
        datatable(
            newData() %>% select(DurakTuru,DurakAdi,MetreMesafe,YuruyusRotası),
            options = list(dom='tip',pageLength = 5, autoWidth = T,bSort=FALSE,scrollX = T), escape = FALSE,selection = 'none', rownames= FALSE)
    )
    
    observeEvent(input$geolocation,{
        if (input$geolocation == FALSE) {
            f7Toast(
                position = "center",
                closeTimeout = 10000,
                closeButtonText = "kapat",
                text = paste0("Merhaba!","</br>","Daha iyi bir uygulama deneyimi icin lutfen konum erisimine izin veriniz.")
            )
        }
        
        if (min(newData()$MetreMesafe) >= 30000) {
            f7Toast(
                position = "top",
                closeTimeout = 20000,
                closeButtonText = "kapat",
                text = paste0("İzmir'e oldukça uzak bir konumda bulunmaktasınız.","</br>","</br>",
                                   "Kent Kameralarından İzmir'i canlı olarak seyretmeye ne dersiniz? ","</br>",
                                   paste0("<a href='", "http://www.izmir.bel.tr/tr/KentKameralari/21/","' target='_blank'>", "http://www.izmir.bel.tr/tr/KentKameralari/21/","</a>")                                   )
            )
        }
    })

    
}