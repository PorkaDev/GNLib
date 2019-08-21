function GNLib.OpenVGUIPanel()
    --if not LocalPlayer():IsAdmin() then return end
    local main = GNLib.CreateFrame( "GNLib - VGui Display" )

    --  > Toggle credits mod
    local toggleButton = vgui.Create( "GNToggleButton", main )
    toggleButton:SetPos( 50, 50 )
    function toggleButton:OnToggled( toggled )
        --if toggled then self:SetEnabled( false ) end
    end

    local progress = vgui.Create( "GNProgress", main )
    progress:SetPos( 50, 100 )
    progress:SetPercentage( 0 )
    progress:SetBarTall( 10 )

    local progressn = vgui.Create( "GNProgress", main )
    progressn:SetPos( 50, 150 )
    progressn:SetShowCircle( false )
    progressn:SetPercentage( 1 )
    progressn:SetSpeed( 1 )

    local slider = vgui.Create( "GNSlider", main )
    slider:SetPos( 50, 200 )
    function slider:OnValueChanged( _, percent )
        progress:SetPercentage( 1 - percent )
    end

    timer.Simple( 5, function()
        if not IsValid( main ) then return end
        progress:SetPercentage( 1 )
        progressn:SetPercentage( 0 )
    end )

    main.oldPaint = main.Paint

    function main:Paint( w, h )
        self:oldPaint( w, h )

        GNLib.DrawOutlinedElipse( 50, 250, 200, 24, 5, GNLib.Colors.Pomegranate )

        GNLib.DrawOutlinedElipse( 300, 250, 200, 24, 1, GNLib.Colors.Emerald )

        GNLib.DrawOutlinedElipse( 600, 250, 200, 24, 10, GNLib.Colors.Amethyst )
    end

    local button = vgui.Create( "GNButton", main )
    button:SetPos( 50, 300 )
    button:SetText( "Bouton ovale tout beau avec un auto update size, wow, amazing :kappa:" )

    local iconbutton = vgui.Create( "GNIconButton", main )
    iconbutton:SetPos( button.x + button:GetWide() + 50, 300 )
    iconbutton:SetRadius( 45 )
    iconbutton:SetIconRadius( 45 )
    iconbutton:SetIcon( Material("games/16/hl2.png","smooth") )

    local textentry = vgui.Create( "GNTextEntry", main )
    textentry:SetPos( 50, 350 )
    textentry:SetSize( 250, 35  )
    textentry:SetTitle( "Your name" )
    textentry:SetFont( "GNLFontB20" )

    local searchentry = vgui.Create( "GNIconTextEntry", main )
    searchentry:SetPos( 50, 400 )
end
concommand.Add( "gnlib_vgui", GNLib.OpenVGUIPanel )
