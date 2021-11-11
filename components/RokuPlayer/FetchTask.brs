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
        m.top.timer.control = "stop"
        m.ourVast = {}

        if m.top.oururi = "test"
            FetchTestChannel()
            return 0
        end if
        m.playerSettings = {}
        plainXMLSettings = fetch({ url: m.top.settingsuri }).xml()
        FetchSettings(plainXMLSettings, 0)

        ourUri = m.top.oururi.Replace("[APP_URL]", m.playerSettings.appStoreURL.Escape()).Trim()
        PrintDebug("URI " + ourUri)

        x = fetch({ url: ourUri }).xml()

        GetVasts(x,0,m.ourVast)
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
        print "It throw exception!"
        print "Number of error ";e.number
        print "Error message text:", e.message
        print "location of the error "
        for i = 0 to e.backtrace.Count() - 1
            print e.backtrace[i]
        end for
        m.top.timer.control = "start"
    end try
end function

function FetchTestChannel()
    testUri = "https://ctv.media/2.xml"
    PrintDebug("testUri loading " + testUri)

    x = fetch({ url: testUri })

    GetVasts(x.xml(), 0,m.ourVast)

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

        y = fetch({ url: m.ourVast.VASTAdTagURI })
        PrintDebug("intermediate Vast " + y.text())

        if y = invalid then return invalid
        GetVasts(y.xml(), 0, m.themVast)
        m.themVasts.push(m.themVast)
    end if
    ctr = 0

    if ctr <= m.top.recurDepth
        while m.themVasts[m.themVasts.Count() - 1].VASTAdTagURI <> invalid
            m.themNewVast = {}
            z = fetch({ url: m.themVasts[m.themVasts.Count() - 1].VASTAdTagURI })

            PrintDebug("next Vast " + z.text())

            if z.status <> 200 or z.text().Trim() = ""
                return 0
            end if
            GetVasts(z.xml(), 0, m.themNewVast)
            m.themVasts.push(m.themNewVast)
            ctr += 1

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

function GetVasts(element as object, depth as integer, vast as object)
    text = element.GetText().Replace(" ", "")
    name = element.GetName()

    if name = "VASTAdTagURI" and text <> ""
        vast.VASTAdTagURI = text
        PrintDebug(" AdTagURI " + vast.VASTAdTagURI)
    end if
    if name = "Impression" and text <> ""
        vast.Impression = text
    end if
    if name = "MediaFile" and text <> ""
        PrintDebug(" MEDIAFILE " + text)
        vast.MediaFile = text
    end if
    if name = "Error" and text <> ""
        vast.Error = text
    end if
    if name = "Tracking"
        if element.GetAttributes()["event"] = "start"
            vast.start = text
        else if element.GetAttributes()["event"] = "firstQuartile"
            vast.FirstQuartile = text
        else if element.GetAttributes()["event"] = "midpoint"
            vast.Midpoint = text
        else if element.GetAttributes()["event"] = "thirdQuartile"
            vast.ThirdQuartile = text
        else if element.GetAttributes()["event"] = "complete"
            vast.Complete = text
        end if

    end if

    if element.GetChildElements() <> invalid
        for each e in element.GetChildElements()
            GetVasts(e, depth + 1, vast)
        end for
    end if
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
    request.SetUrl(options.url)

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
                PrintDebug("STATUS " + str(status).Trim())
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
    if LCase(text) = "true"
        return true
    end if
    return false
end function