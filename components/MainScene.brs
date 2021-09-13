' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.top.SetFocus(true)

    label = m.top.FindNode("testLabel")
    label.font.size = 92
    label.color = "0x72D7EEFF"


    'Example of starting Ad player
    m.rokuPlayer = m.top.findNode("Rokuplayer")
    m.rokuPlayer.channelName = "eabace85" 'THIS IS A Test channel. Please change this with your channel.
    m.rokuPlayer.appName = "Test"
    m.rokuPlayer.appBundleId = "com.company.test"
    m.rokuPlayer.countGames = 3
    m.rokuPlayer.callFunc("startWork")
End sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    
    return result 
end function
