' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.top.SetFocus(true)

    label = m.top.FindNode("testLabel")
    label.font.size = 92
    label.color = "0x72D7EEFF"

    'Example of starting Ad player
    m.rokuPlayer = m.top.findNode("Rokuplayer")
    m.rokuPlayer.channelName = "Test" 'THIS IS A Test channel. Please change this with your channel.
    m.rokuPlayer.appName = "Test"
    m.rokuPlayer.publisher = "2ebb4ec4" 'THIS IS A Test publisher. Please change this with your publisher.
    m.rokuPlayer.countGames = 3
    m.rokuPlayer.debug = true
    'm.rokuPlayer.bgmNode = m.audioBackground 'To automatically turn on and off the game's background music. You can assign to this variable 
    
    'Control buttons setting section
    m.rokuPlayer.AdBackButton = "Back"
    m.rokuPlayer.AdDirectionButton = "Direction"
    m.rokuPlayer.AdOKButton = "OK"
    m.rokuPlayer.AdReplayButton = "Replay"
    m.rokuPlayer.AdRewindButton = "Rewind"
    m.rokuPlayer.AdPlayButton = "Play/Pause"
    m.rokuPlayer.AdFastforwardButton = "Fastforward"

    m.rokuPlayer.callFunc("startWork")
End sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false

    return result 
end function
