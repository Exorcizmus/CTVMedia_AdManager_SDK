' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********  

sub init()
    m.top.SetFocus(true)

    label = m.top.FindNode("testLabel")
    label.font.size = 92
    label.color = "0x72D7EEFF"
End sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    result = false
    
    return result 
end function
