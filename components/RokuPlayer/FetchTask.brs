sub init()
    m.top.functionName = "CallFunc"
end sub

sub PrintDebug(message)
    if m.top.debug = true
        print message
    end if
end sub

function CallFunc()
    try
    m.playerSettings = {}
    plainXMLSettings = fetch({ url: m.top.settingsuri }).xml()
    FetchSettings(plainXMLSettings, 0)
    
    ourUri = m.top.oururi.Replace("[APP_URL]", m.playerSettings.appStoreURL.EncodeUri()).Trim()
    PrintDebug("URI " + ourUri)

    x = fetch({ url: ourUri }).xml()
    
    m.ourVast = {}

    NewOurVast(x, 0)
    if m.ourVast.MediaFile = invalid
        FetchThem()
        if MediaCheck(m.themVasts)
            res = [m.ourVast, m.themVasts, m.playerSettings]
            m.top.res = res
        else
            FetchTestChannel()
        end if
    else
        FetchDirectVideo()
    end if
    catch e
        PRINT "It went wrong:",e.message
    end try
end function

function FetchTestChannel()
    testUri = m.top.testuri.Replace("[APP_URL]", m.playerSettings.appStoreURL.EncodeUri()).Trim()
    PrintDebug("testUri loading" + testUri)
        
    x = fetch({ url: testUri }).xml()
    NewOurVast(x, 0)

    arr = []
    arr.push(m.ourVast)

    res = [m.ourVast, arr, m.playerSettings]
    m.top.res = res

end function

function FetchDirectVideo()
    arr = []
    arr.push(m.ourVast)

    res = [m.ourVast, arr, m.playerSettings]
    m.top.res = res
end function

function FetchThem()
    if m.ourVast.VASTAdTagURI <> invalid
        m.themVasts = []
        m.themVast = {}
        m.themVast.VASTAdTagURI = []
        m.themVast.Impression = []
        m.themVast.start = []
        m.themVast.FirstQuartile = []
        m.themVast.Midpoint = []
        m.themVast.ThirdQuartile = []
        m.themVast.Complete = []

        y = fetch({ url: m.ourVast.VASTAdTagURI }).xml()
        if y = invalid then return invalid
        FetchThemVast(y, 0)
        m.themVasts.push(m.themVast)
    end if
    ctr = 0

    if ctr <= m.top.recurDepth
        while m.themVasts[m.themVasts.Count() - 1].VASTAdTagURI.Count() <> 0
            m.themNewVast = {}
            m.themNewVast.VASTAdTagURI = []
            m.themNewVast.Impression = []
            m.themNewVast.start = []
            m.themNewVast.FirstQuartile = []
            m.themNewVast.Midpoint = []
            m.themNewVast.ThirdQuartile = []
            m.themNewVast.Complete = []
            z = fetch({ url: m.themVasts[m.themVasts.Count() - 1].VASTAdTagURI[0] })
        
            PrintDebug("next Vast " + z.text())

            if z.status <> 200 or z.text() = "" or z.text().Trim() = ""
                return 0
            end if
            FetchThemNewVast(z.xml(), 0)
            m.themVasts.push(m.themNewVast)
            ctr +=1
    
        end while
    end if
    'print ctr
end function

function MediaCheck(arrays) as boolean
    for each obj in arrays
        if obj.mediafile <> invalid
            return true
        end if
    end for

    return false
end function

function FetchSettings(elements as object, depth as integer)
    for each elem in elements.GetChildElements()
        if elem.GetName() = "show_skip"
            m.playerSettings.showSkip = GetBooleanFromString(elem.GetText())
        else if elem.GetName() = "skip_time_before_end"
            m.playerSettings.skipTimeBeforeEnd = elem.GetText().toInt()
        else if elem.GetName() = "show_ad_between_levels"
            m.playerSettings.showAdBetweenLevels = GetBooleanFromString(elem.GetText())
        else if elem.GetName() = "show_ad_interval"
            m.playerSettings.showAdInterval = elem.GetText().toInt()
        else if elem.GetName() = "app_store_url"
            m.playerSettings.appStoreURL = elem.GetText()
        end if
        
    end for
end function

function FetchThemVast(element as object, depth as integer)

    if element.GetName() = "VASTAdTagURI"
        m.themVast.VASTAdTagURI.push(element.GetText())
    end if
    if element.GetName() = "Impression"
        m.themVast.Impression.push(element.GetText())
    end if
    if element.GetName() = "Error"
        m.themVast.Error = element.GetText()
    end if
    if element.GetName() = "MediaFile"
        PrintDebug(" MEDIAFILE " + element.GetText())
        m.themVast.MediaFile = element.GetText()
    end if
    if element.GetName() = "Tracking"
        if element.GetAttributes()["event"] = "start"
            m.themVast.start.push(element.GetText())
        else if element.GetAttributes()["event"] = "firstQuartile"
            m.themVast.FirstQuartile.push(element.GetText())
        else if element.GetAttributes()["event"] = "midpoint"
            m.themVast.Midpoint.push(element.GetText())
        else if element.GetAttributes()["event"] = "thirdQuartile"
            m.themVast.ThirdQuartile.push(element.GetText())
        else if element.GetAttributes()["event"] = "complete"
            m.themVast.Complete.push(element.GetText())
        end if

    end if

    'print depth * 3;"Name: ";element.GetName()
    if not element.GetAttributes().IsEmpty() then
        'print depth * 3;"Attributes: ";
        for each a in element.GetAttributes()
            'print a;"=";left(element.GetAttributes()[a], 20);
            if element.GetAttributes().IsNext() then print ", ";
        end for
        'print
    end if
    if element.GetText() <> invalid then
        'print depth * 3;"Contains Text: ";element.GetText()
    end if
    if element.GetChildElements() <> invalid
        'print depth * 3;"Contains roXMLList:"
        for each e in element.GetChildElements()
            'print depth; " depth"
            FetchThemVast(e, depth + 1)
        end for
    end if
end function

function FetchThemNewVast(element as object, depth as integer)

    if element.GetName() = "VASTAdTagURI"
        m.themNewVast.VASTAdTagURI.push(element.GetText())
    end if
    if element.GetName() = "Impression"
        m.themNewVast.Impression.push(element.GetText())
    end if
    if element.GetName() = "Error"
        m.themNewVast.Error = element.GetText()
    end if
    if element.GetName() = "MediaFile"
        PrintDebug(" MEDIAFILE " + element.GetText())
        m.themNewVast.MediaFile = element.GetText()
    end if
    if element.GetName() = "Tracking"
        if element.GetAttributes()["event"] = "start"
            m.themNewVast.start.push(element.GetText())
        else if element.GetAttributes()["event"] = "firstQuartile"
            m.themNewVast.FirstQuartile.push(element.GetText())
        else if element.GetAttributes()["event"] = "midpoint"
            m.themNewVast.Midpoint.push(element.GetText())
        else if element.GetAttributes()["event"] = "thirdQuartile"
            m.themNewVast.ThirdQuartile.push(element.GetText())
        else if element.GetAttributes()["event"] = "complete"
            m.themNewVast.Complete.push(element.GetText())
        end if

    end if

    'print depth * 3;"Name: ";element.GetName()
    if not element.GetAttributes().IsEmpty() then
        'print depth * 3;"Attributes: ";
        for each a in element.GetAttributes()
            'print a;"=";left(element.GetAttributes()[a], 20);
            if element.GetAttributes().IsNext() then print ", ";
        end for
        'print
    end if
    if element.GetText() <> invalid then
        'print depth * 3;"Contains Text: ";element.GetText()
    end if
    if element.GetChildElements() <> invalid
        'print depth * 3;"Contains roXMLList:"
        for each e in element.GetChildElements()
            'print depth; " depth"
            FetchThemNewVast(e, depth + 1)
        end for
    end if
end function

function NewOurVast(element as object, depth as integer)
    'vast = {}
    if element.GetName() = "VASTAdTagURI"
        m.ourVast.VASTAdTagURI = element.GetText()
        PrintDebug(" AdTagURI " + element.GetText())
    end if
    if element.GetName() = "Impression"
        m.ourVast.Impression = element.GetText()
    end if
    if element.GetName() = "MediaFile"
        PrintDebug(" MEDIAFILE " + element.GetText())
        m.ourVast.MediaFile = element.GetText()
    end if
    if element.GetName() = "Error"
        m.ourVast.Error = element.GetText()
    end if
    if element.GetName() = "Tracking"
        if element.GetAttributes()["event"] = "start"
            m.ourVast.start = element.GetText()
        else if element.GetAttributes()["event"] = "firstQuartile"
            m.ourVast.FirstQuartile = element.GetText()
        else if element.GetAttributes()["event"] = "midpoint"
            m.ourVast.Midpoint = element.GetText()
        else if element.GetAttributes()["event"] = "thirdQuartile"
            m.ourVast.ThirdQuartile = element.GetText()
        else if element.GetAttributes()["event"] = "complete"
            m.ourVast.Complete = element.GetText()
        end if

    end if

    'print depth*3;"Name: ";element.GetName()
    if not element.GetAttributes().IsEmpty() then
        'print depth*3;"Attributes: ";
        for each a in element.GetAttributes()
            'print a;"=";left(element.GetAttributes()[a], 20);
            if element.GetAttributes().IsNext() then print ", ";
        end for
        'print
    end if
    if element.GetText() <> invalid then
        'print depth*3;"Contains Text: ";element.GetText()
    end if
    if element.GetChildElements() <> invalid
        'print depth*3;"Contains roXMLList:"
        for each e in element.GetChildElements()
            NewOurVast(e, depth + 1)
        end for
    end if
    'print
end function

'
function fetch(options)
    timeout = options.timeout
    if timeout = invalid then timeout = 0

    response = invalid
    port = CreateObject("roMessagePort")
    request = CreateObject("roUrlTransfer")
    request.SetCertificatesFile("common:/certs/ca-bundle.crt")
    request.InitClientCertificates()
    request.RetainBodyOnError(true)
    request.SetMessagePort(port)
    if options.headers <> invalid
        for each header in options.headers
            val = options.headers[header]
            if val <> invalid then request.addHeader(header, val)
        end for
    end if
    if options.method <> invalid
        request.setRequest(options.method)
    end if
    request.SetUrl(options.url.Replace("https","http"))

    requestSent = invalid
    if options.body <> invalid
        requestSent = request.AsyncPostFromString(options.body)
    else
        requestSent = request.AsyncGetToString()
    end if
    if (requestSent)
        msg = wait(timeout, port)
        status = -999
        body = "(TIMEOUT)"
        headers = {}
        if (type(msg) = "roUrlEvent")
            status = msg.GetResponseCode()
            if status <> 200
                PrintDebug("STATUS " + status)
                PrintDebug(msg.GetFailureReason())
                'stop
            end if
            headersArray = msg.GetResponseHeadersArray()
            for each headerObj in headersArray
                for each headerName in headerObj
                    val = {
                        value: headerObj[headerName]
                        next: invalid
                    }
                    current = headers[headerName]
                    if current <> invalid
                        prev = current
                        while current <> invalid
                            prev = current
                            current = current.next
                        end while
                        prev.next = val
                    else
                        headers[headerName] = val
                    end if
                end for
            end for
            body = msg.GetString()
            if status < 0 then body = msg.GetFailureReason()
        end if

        response = {
            _body: body,
            status: status,
            ok: (status >= 200 and status < 300),
            headers: headers,
            text: function()
                return m._body
            end function,
            json: function()
                return ParseJSON(m._body)
            end function,
            xml: function()
                if m._body = invalid then return invalid
                xml = CreateObject("roXMLElement") '
                if not xml.Parse(m._body) then return invalid
                return xml
            end function
        }
    end if

    return response
end function

function GetBooleanFromString(text as string) as boolean
    if text = "True" or text = "true"
        return true
    end if
    return false
end function