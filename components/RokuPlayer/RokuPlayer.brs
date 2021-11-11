'roku51Games SDK Ad player
sub init()
    m.appName = m.top.appName

    m.firstRun = true
    m.video = m.top.findNode("adVideo")
    m.video.ObserveField("state", "VideoStateChanged")
    m.video.ObserveField("position", "VideoTimeChanged")


    m.timer = m.top.findNode("adTimer")
    m.timer.ObserveField("fire", "work")


    m.slidePoster = m.top.findNode("sliderPoster")
    changeLogo()
    m.sliderTimer = m.top.findNode("sliderTimer")
    m.sliderTimer.ObserveField("fire", "changeLogo")
    m.sliderTimer.control = "start"
end sub

sub setControlButtons()
    AdBackButton = m.top.findNode("AdBackButton")
    AdBackButton.text = m.top.AdBackButton
    AdDirectionButton = m.top.findNode("AdDirectionButton")
    AdDirectionButton.text = m.top.AdDirectionButton
    AdOKButton = m.top.findNode("AdOKButton")
    AdOKButton.text = m.top.AdOKButton
    AdReplayButton = m.top.findNode("AdReplayButton")
    AdReplayButton.text = m.top.AdReplayButton
    AdRewindButton = m.top.findNode("AdRewindButton")
    AdRewindButton.text = m.top.AdRewindButton
    AdPlayButton = m.top.findNode("AdPlayButton")
    AdPlayButton.text = m.top.AdPlayButton
    AdFastforwardButton = m.top.findNode("AdFastforwardButton")
    AdFastforwardButton.text = m.top.AdFastforwardButton
end sub

function GetDeviceDataAndSettings()
    if m.firstRun = true
        m.di = GetDeviceInfo()
        m.ip = m.di.GetExternalIp()
        m.displaySize = m.di.GetDisplaySize()
        m.devId = m.di.GetChannelClientId()
        m.model = m.di.GetModel()
        appInfo = CreateObject("roAppInfo")
        m.bundleId = appInfo.GetID()
    end if
end function

function SendInventory()
    if m.firstRun = true
        inventoryLink = "https://vast.ctv.media/inventory?channel=[CHANNEL_NAME]&publisher=[PUBLISHER]&ip=[IP_ADDRESS]&width=[WIDTH]&height=[HEIGHT]&appName=[APP_NAME]&appBundle=[APP_BUNDLE_ID]"
        inventoryLink = inventoryLink.Replace("[IP_ADDRESS]", m.ip)
        inventoryLink = inventoryLink.Replace("[WIDTH]", str(m.displaySize.w))
        inventoryLink = inventoryLink.Replace("[HEIGHT]", str(m.displaySize.h))
        inventoryLink = inventoryLink.Replace("[APP_NAME]", m.top.appName)
        inventoryLink = inventoryLink.Replace("[APP_BUNDLE_ID]", m.bundleId)
        inventoryLink = inventoryLink.Replace("[CHANNEL_NAME]", m.top.channelName)
        inventoryLink = inventoryLink.Replace("[PUBLISHER]", m.top.publisher)
        inventoryLink = inventoryLink.Replace(" ", "")

        SendData(inventoryLink)
    end if
end function


function changeLogo()
    logoNum = Rnd(m.top.countGames)
    m.slidePoster.uri = "pkg:/components/RokuPlayer/GameLogos/" + str(logoNum).Trim() + ".png"
end function

sub PrintDebug(message)
    if m.top.debug = true
        print message
    end if
end sub

function startWork()
    setControlButtons()
    m.timer.control = "start"
    PrintDebug("timer started")
end function

function work()
    PrintDebug("timer fired")

    GetDeviceDataAndSettings()
    SendInventory()

    PrintDebug(m.top.channelName + " Channel name")
    PrintDebug(m.displaySize)

    if LCase(m.top.channelName) <> "test"
        settingsAddress = "https://vast.ctv.media/player?channel=[CHANNEL_NAME]"

        address = "https://vast.ctv.media/?channel=[CHANNEL_NAME]&width=[WIDTH]&height=[HEIGHT]&ip=[IP_ADDRESS]&appName=[APP_NAME]&appBundle=[APP_BUNDLE_ID]&device_model=[DEVICE_MODEL]&deviceId=[DEVICE_ID]&publisher=[PUBLISHER]"

        address = address.Replace("[IP_ADDRESS]", m.ip)
        address = address.Replace("[WIDTH]", "1920")
        address = address.Replace("[HEIGHT]", "1080")
        address = address.Replace("[APP_NAME]", m.top.appName)
        address = address.Replace("[APP_BUNDLE_ID]", m.bundleId)
        address = address.Replace("[PUBLISHER]", m.top.publisher)
        '
        address = address.Replace("[DEVICE_MODEL]", m.model)
        address = address.Replace("[DEVICE_ID]", m.devId)

        address = address.Replace("[CHANNEL_NAME]", m.top.channelName)
        settingsAddress = settingsAddress.Replace("[CHANNEL_NAME]", m.top.channelName)

        address = address.Replace(" ", "")
        address = address + "&appURL=[APP_URL]"

        settingsAddress = settingsAddress.Replace(" ", "")
    else
        'Test channel calling
        PrintDebug("Test channel calling")
        address = LCase(m.top.channelName)
    end if
        m.fetchTask = CreateObject("roSGNode", "FetchTask")
        m.fetchTask.setField("oururi", address)
        m.fetchTask.setField("settingsuri", settingsAddress)
        m.fetchTask.setField("recurDepth", m.top.recurDepth)
        m.fetchTask.setField("debug", m.top.debug)
        m.fetchTask.setField("timer", m.timer)
        m.fetchTask.observeField("res", "PlayAd")
        m.fetchTask.control = "RUN"

        m.firstRun = false
end function

sub SetBGMNode()
    m.bgm = m.top.bgmNode
end sub

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
    m.video.mute = m.top.muteAdVideo
    if m.video.position > m.video.duration * 0.25 and m.firstquartileFlag = false
        SendTracks("firstquartile")
        m.firstquartileFlag = true
    else if m.video.position > m.video.duration * 0.5 and m.midpointFlag = false
        SendTracks("midpoint")
        m.midpointFlag = true
    else if m.video.position > m.video.duration * 0.75 and m.ThirdQuartileFlag = false
        SendTracks("thirdQuartile")
        m.ThirdQuartileFlag = true
    end if
end function

function ShowSkipButton()
    m.skipButt.visible = true
    m.skipButt.setFocus(true)
    m.skipButt.ObserveField("buttonSelected", "SkipButtonPushed")
end function

function SendData(uri)
    if type(uri) = "roString" or type(uri) = "String"
        PrintDebug("we sending " + uri)
        m.sendDataTask = CreateObject("roSGNode", "SendDataTask")
        m.sendDataTask.setField("dataUri", uri)
        m.sendDataTask.control = "RUN"
    else if type(uri) = "roArray"
        for each item in uri
            PrintDebug("we sending " + item)
            m.sendDataTask = CreateObject("roSGNode", "SendDataTask")
            m.sendDataTask.setField("dataUri", item)
            m.sendDataTask.control = "RUN"
        end for
    else
        PrintDebug("URI is incorrect " + uri)
        PrintDebug(type(uri) + " typeof uri")
    end if

end function

function checkField(field) as boolean
    if field <> invalid
        if field.Trim() <> ""
            return true
        end if
    end if

    return false
end function

function SendTracks(trackType as string)
    'Impression
    for i = 0 to m.resultArr[1].Count() - 1
        if trackType = "impression"
            if checkField(m.resultArr[1][i].impression) = true
                SendData(m.resultArr[1][i].impression)
            end if
        else if trackType = "complete"
            if checkField(m.resultArr[1][i].complete) = true
                SendData(m.resultArr[1][i].complete)
            end if
        else if trackType = "error"
            if checkField(m.resultArr[1][i].error) = true
                t = m.resultArr[1][i].error.Replace("[ERRORCODE]", "303")
                t = t.Replace(" ", "")
                SendData(t)
            end if
        else if trackType = "start"
            if checkField(m.resultArr[1][i].start) = true
                SendData(m.resultArr[1][i].start)
            end if
        else if trackType = "firstquartile"
            if checkField(m.resultArr[1][i].firstquartile) = true
                SendData(m.resultArr[1][i].firstquartile)
            end if
        else if trackType = "midpoint"
            if checkField(m.resultArr[1][i].midpoint) = true
                SendData(m.resultArr[1][i].midpoint)
            end if
        else if trackType = "thirdQuartile"
            if checkField(m.resultArr[1][i].thirdQuartile) = true
                SendData(m.resultArr[1][i].thirdQuartile)
            end if
        end if
    end for

    if trackType = "impression"
        if checkField(m.resultArr[0].impression) = true
            SendData(m.resultArr[0].impression)
        end if
    else if trackType = "complete"
        if checkField(m.resultArr[0].complete) = true
            SendData(m.resultArr[0].complete)
        end if

    else if trackType = "error"
        if checkField(m.resultArr[0].error) = true
            t = m.resultArr[0].error.Replace("[ERRORCODE]", "303")
            t = t.Replace(" ", "")
            SendData(t)
        end if

    else if trackType = "start"
        if checkField(m.resultArr[0].start) = true
            SendData(m.resultArr[0].start)
        end if

    else if trackType = "firstquartile"
        if checkField(m.resultArr[0].firstquartile) = true
            SendData(m.resultArr[0].firstquartile)
        end if

    else if trackType = "midpoint"
        if checkField(m.resultArr[0].midpoint) = true
            SendData(m.resultArr[0].midpoint)
        end if

    else if trackType = "thirdQuartile"
        if checkField(m.resultArr[0].thirdQuartile) = true
            SendData(m.resultArr[0].thirdQuartile)
        end if

    end if
end function

function VideoStateChanged()
    PrintDebug("state " + m.video.state)
    if m.video.state = "error"
        m.video.control = "none" 'stop the Ad
        m.video.visible = false 'show the game
        m.videoAdError = true 'flag for finished state
        SendTracks("error") 'sending tracks
        PrintVidError()
        if m.bgm <> invalid then m.bgm.control = "play"
        m.timer.control = "start"
    end if
    if m.video.state = "finished" and m.videoAdError = false 'if truly finish ad
        m.video.visible = false 'show the game
        SendTracks("complete") 'sending tracks
        m.timer.control = "start"
        if m.bgm <> invalid then m.bgm.control = "play"
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
        if m.bgm <> invalid then m.bgm.control = "stop"

        videoContent = createObject("RoSGNode", "ContentNode")
        vstCnt = m.resultArr[1].Count()

        videoContent.url = m.resultArr[1][vstCnt - 1].mediafile.Trim()


        m.video.visible = true
        m.video.content = videoContent
        m.video.control = "play"

    end if
end function

sub PrintVidError()
    print m.video.errorCode;" errorCode"
    print m.video.errorMsg;" errorMsg"
    print m.video.errorStr;" errorStr"
    print m.video.errorInfo;" errorInfo"
    print m.video.contentBlocked;" contentBlocked"
    print m.video.captionStyle;" captionStyle"
    print m.video.videoFormat;" videoFormat"
    print m.video.bufferingStatus;" bufferingStatus"
    print m.video.streamInfo;" streamInfo"
end sub