'roku51Games SDK Ad player 
sub init()
    m.appName = m.top.appName
    m.appBundleId = m.top.appBundleId

    m.firstRun = true
    m.video = m.top.findNode("adVideo")
    m.video.ObserveField("state","VideoStateChanged")
    m.video.ObserveField("position","VideoTimeChanged")
    

    m.timer = m.top.findNode("adTimer")
    m.timer.ObserveField("fire","work")

    
    m.slidePoster = m.top.findNode("sliderPoster")
    changeLogo()
    m.sliderTimer = m.top.findNode("sliderTimer")
    m.sliderTimer.ObserveField("fire","changeLogo")
    m.sliderTimer.control = "start" 

    m.sendTrackFlag = true
end sub

function GetDeviceDataAndSettings()
    if m.firstRun = true
        m.di = GetDeviceInfo()
        m.ip = m.di.GetExternalIp()
        m.displaySize = m.di.GetDisplaySize()
        m.devId = m.di.GetChannelClientId()
        m.model = m.di.GetModel()
        m.channelName = m.top.channelName
    end if
end function

function SendInventory()
    if m.firstRun = true
        inventoryLink = "https://vast.ctv.media/inventory?channel=[CHANNEL_NAME]&publisher=2ebb4ec4&ip=[IP_ADDRESS]&width=[WIDTH]&height=[HEIGHT]&appName=[APP_NAME]&appBundle=[APP_BUNDLE_ID]"
        inventoryLink = inventoryLink.Replace("[IP_ADDRESS]", m.ip)
        inventoryLink = inventoryLink.Replace("[WIDTH]", str(m.displaySize.w))
        inventoryLink = inventoryLink.Replace("[HEIGHT]", str(m.displaySize.h))
        inventoryLink = inventoryLink.Replace("[APP_NAME]", m.appName)
        inventoryLink = inventoryLink.Replace("[APP_BUNDLE_ID]", m.appBundleId)
        inventoryLink = inventoryLink.Replace("[CHANNEL_NAME]", m.channelName)
        inventoryLink = inventoryLink.Replace(" ", "")

        SendData(inventoryLink)
    end if
end function


function changeLogo()
    logoNum = Rnd(m.top.countGames)
    m.slidePoster.uri="pkg:/components/RokuPlayer/GameLogos/" + str(logoNum).Trim() + ".png"
end function

function startWork()
    m.timer.control = "start" 
    print "timer started"
end function

function work()
    print "timer fired"
    testChannelName = "4998636"

    GetDeviceDataAndSettings()
    SendInventory()

    print m.channelName
    print m.displaySize

    settingsAddress = "https://vast.ctv.media/player?channel=[CHANNEL_NAME]"
    
    address = "https://vast.ctv.media/?channel=[CHANNEL_NAME]&width=[WIDTH]&height=[HEIGHT]&uip=[IP_ADDRESS]&appName=[APP_NAME]&appBundle=[APP_BUNDLE_ID]&device_model=[DEVICE_MODEL]&deviceId=[DEVICE_ID]&publisher=2ebb4ec4"
    
    address = address.Replace("[IP_ADDRESS]",m.ip)
    address = address.Replace("[WIDTH]", str(m.displaySize.w))
    address = address.Replace("[HEIGHT]", str(m.displaySize.h))
    address = address.Replace("[APP_NAME]", m.appName)
    address = address.Replace("[APP_BUNDLE_ID]", m.appBundleId)
    '
    address = address.Replace("[DEVICE_MODEL]", m.model)
    address = address.Replace("[DEVICE_ID]", m.devId)

    testAddress = address
    address = address.Replace("[CHANNEL_NAME]", m.channelName)
    testAddress = testAddress.Replace("[CHANNEL_NAME]", testChannelName)
    
    settingsAddress = settingsAddress.Replace("[CHANNEL_NAME]", m.channelName)
    
    address = address.Replace(" ", "")
    address = address + "&appURL=[APP_URL]"

    testAddress = testAddress.Replace(" ", "")
    testAddress = testAddress + "&appURL=[APP_URL]"

    settingsAddress = settingsAddress.Replace(" ", "")


    m.fetchTask = CreateObject("roSGNode", "FetchTask")
   
    
    m.fetchTask.setField("oururi", address)
    m.fetchTask.setField("testuri", testAddress)
    m.fetchTask.setField("settingsuri", settingsAddress)
    m.fetchTask.setField("recurDepth" , m.top.recurDepth)
    m.fetchTask.observeField("res", "PlayAd")
    m.fetchTask.control = "RUN"

    m.firstRun = false
end function

function GetDeviceInfo() as object
    di = CreateObject("roDeviceInfo")
    return di
end function

function MediaCheck(arrays) as boolean
    for each obj in arrays
        if obj.mediafile <> invalid
            return true
        end if
    end for

    return false
end function



function VideoTimeChanged()
    'print "time ";m.video.position
    'print m.global.muteAdVideo
    m.video.mute = m.global.muteAdVideo
        if m.video.position > m.video.duration * 0.25 and m.firstquartileFlag = false
            SendTracks("firstquartile")
            m.firstquartileFlag = true
        else if m.video.position > m.video.duration * 0.5 and m.midpointFlag = false
            SendTracks("midpoint")
            m.midpointFlag = true
        else if m.video.position > m.video.duration * 0.75 and m.ThirdQuartileFlag = false
            SendTracks("thirdQuartile")
            m.ThirdQuartileFlag = true 
        else if m.video.position > m.video.duration - m.settingPLayer.skiptimebeforeend and m.settingPLayer.showskip = true
            'ShowSkipButton()
        end if
end function

function ShowSkipButton()
    m.skipButt.visible = true
    m.skipButt.setFocus(true)
    m.skipButt.ObserveField("buttonSelected", "SkipButtonPushed")
end function

function SendData(uri)
    if type(uri) = "roString" OR type(uri) = "String"
        print "we sending ";uri
        m.sendDataTask = CreateObject("roSGNode", "SendDataTask")
        m.sendDataTask.setField("dataUri",uri)
        m.sendDataTask.control = "RUN"
    else if type(uri) = "roArray"
        for each item in uri
            print "we sending ";item
            m.sendDataTask = CreateObject("roSGNode", "SendDataTask")
            m.sendDataTask.setField("dataUri",item)
            m.sendDataTask.control = "RUN"
        end for
    else
        print "URI is incorrect ";uri
        print type(uri);" typeof uri"
    end if
    
end function

function SendTracks(trackType as string)
    if m.sendTrackFlag = false
        return 0
    end if
    'Impression
    for i=0 to m.resultArr[1].Count()-1
        if trackType = "impression"
            if m.resultArr[1][i].impression <> invalid
                SendData(m.resultArr[1][i].impression)
            end if
        else if trackType = "complete"
            
            if m.resultArr[1][i].complete <> invalid
                SendData(m.resultArr[1][i].complete)
            end if
        else if trackType = "error"
            
            if m.resultArr[1][i].error <> invalid
                t = m.resultArr[1][i].error.Replace("[ERRORCODE]", "303")
                t = t.Replace(" ", "")
                SendData(t)
            end if  
        else if trackType = "start"  
            
            if m.resultArr[1][i].start <> invalid
                SendData(m.resultArr[1][i].start)
            end if   
        else if trackType = "firstquartile"  
            
            if m.resultArr[1][i].firstquartile <> invalid
                SendData(m.resultArr[1][i].firstquartile)
            end if      
        else if trackType = "midpoint"  
            
            if m.resultArr[1][i].midpoint <> invalid
                SendData(m.resultArr[1][i].midpoint)
            end if  
        else if trackType = "thirdQuartile"  
            
            if m.resultArr[1][i].thirdQuartile <> invalid
                SendData(m.resultArr[1][i].thirdQuartile)
            end if              
        end if
    end for

    if trackType = "impression"
        if m.resultArr[0].impression <> invalid
            SendData(m.resultArr[0].impression)
        end if
    else if trackType = "complete"
        if m.resultArr[0].complete <> invalid
            SendData(m.resultArr[0].complete)
        end if
        
    else if trackType = "error"
        if m.resultArr[0].error <> invalid
            t = m.resultArr[0].error.Replace("[ERRORCODE]", "303")
            t = t.Replace(" ", "")
            SendData(t)
        end if  
        
    else if trackType = "start"  
        if m.resultArr[0].start <> invalid
            SendData(m.resultArr[0].start)
        end if  
        
    else if trackType = "firstquartile"  
        if m.resultArr[0].firstquartile <> invalid
            SendData(m.resultArr[0].firstquartile)
        end if  
          
    else if trackType = "midpoint"  
        if m.resultArr[0].midpoint <> invalid
            SendData(m.resultArr[0].midpoint)
        end if  
        
    else if trackType = "thirdQuartile"  
        if m.resultArr[0].thirdQuartile <> invalid
            SendData(m.resultArr[0].thirdQuartile)
        end if 
               
    end if
end function

function VideoStateChanged()
    print "state ";m.video.state
    if m.video.state = "error"
        m.video.control = "none" 'stop the Ad
        m.video.visible = false 'show the game
        m.videoAdError = true 'flag for finished state
        SendTracks("error") 'sending tracks
        'StartControl()
    end if
    if m.video.state = "finished" and m.videoAdError = false 'if truly finish ad
        m.video.visible = false 'show the game
        SendTracks("complete") 'sending tracks
        m.timer.control = "start"
       
    else if m.video.state = "playing"
        SendTracks("impression")
        SendTracks("start")
    end if
    
end function

function PlayAd()
    if m.fetchTask.res = invalid then return 0
    m.settingPLayer = m.fetchTask.res[2]
    
    m.videoAdError = false
    
    m.firstquartileFlag = false
    m.midpointFlag = false
    m.ThirdQuartileFlag = false
    
    m.resultArr = m.fetchTask.res

    if MediaCheck(m.resultArr[1]) = true
        m.timer.control = "stop"
    
        videoContent = createObject("RoSGNode", "ContentNode")
        vstCnt = m.resultArr[1].Count()
       
        if Instr(1, m.resultArr[1][vstCnt-1].mediafile, "magic-tech.ru") <> 0
            m.sendTrackFlag = false
        else
            m.sendTrackFlag = true
        end if

        videoContent.url = m.resultArr[1][vstCnt-1].mediafile.Trim()


        m.video.visible = true
        m.video.content = videoContent
        m.video.control = "play"
        'PrintVidError()

    end if
end function

sub PrintVidError()
    print  m.video.errorCode;" errorCode"
    print  m.video.errorMsg;" errorMsg"
    print  m.video.errorStr;" errorStr"
    print  m.video.errorInfo;" errorInfo"
    print  m.video.contentBlocked;" contentBlocked"
    print  m.video.captionStyle;" captionStyle"
    print  m.video.videoFormat;" videoFormat"
    print  m.video.bufferingStatus;" bufferingStatus"
    print  m.video.streamInfo;" streamInfo"
end sub