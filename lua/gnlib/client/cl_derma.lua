--  > Main GNLib frame styled
--- @title:
--- 	GNLib.CreateFrame: <function> Create a centered GNFrame VGUI
--- @params:
--- 	title: <string> Title of the frame
--- 	W: <number> (optional) Width
--- 	H: <number> (optional) Height
--- 	main_color: <Color> (optional) Main color
--- 	second_color: <Color> (optional) Second color
--- @return:
--- 	main: <GNFrame> Main frame
--- 	header: <DPanel> Header of the main frame
--- 	close: <DButton> Close button parented to the header
--- @example:
--- 	#prompt: Code from `lua/gnlib/client/cl_addonslist.lua` line 18
--- 	#code: local main, header, close = GNLib.CreateFrame( "GNLib Addons List - " .. GNLib.Version )
--- 	#output: Create a basic GNFrame and put return values in local variables
function GNLib.CreateFrame( title, W, H, main_color, second_color )
    local W, H = W or math.max( ScrW() * .75, 1024 ), H or math.max( ScrH() * .75, 720 )

    local frame = vgui.Create( "GNFrame" )
        frame:SetTitle( title )
        frame:SetSize( W, H )
        frame:Center()
        if main_color then frame:SetColor( main_color ) end
        if second_color then frame.header.color = second_color end

    return frame, frame.header, frame.close
end

function GNLib.DermaMessage( title, text, button_text, callback )
    title = title or "Title"
    text = text or "Text"
    button_text = button_text or "OK"

    local frame, close = GNLib.CreateFrame( title )
    frame:SetSize( ScrW() / 7, ScrH() / 7 )
    frame:Center()

    local W, H = frame:GetSize()
    close:SetPos( W - 30, 5 )

    local label = vgui.Create( "DLabel", frame )
    label:SetSize( W - 30, H - H / 4 )
    label:SetPos( 15, 30 )
    label:SetText( text )
    label:SetFont( "GNLFontB15" )
    label:SetAutoStretchVertical( true )
    label:SetWrap( true )

    local button = vgui.Create( "GNButton", frame )
    button:SetPos( W / 2 - button:GetWide() / 2, H / 2 - button:GetTall() / 2 + H / 2.8 )
    button:SetText( button_text )
    button:SetColor( GNLib.Colors.Clouds )
    button:SetHoveredColor( GNLib.Colors.Silver )
    function button:DoClick()
        frame:Remove()
        if callback then callback() end
    end

    return frame
end

function GNLib.DermaStringRequest( title, confirm_text, cancel_text, callback, ... )
    title = title or "Title"
    text = text or "Text"
    confirm_text = confirm_text or "OK"
    cancel_text = cancel_text or "Cancel"

    local args = { ... }

    local frame, header, close = GNLib.CreateFrame( title, ScrW() / 5, 50 * #args + 30 * #args + 25 )
        close:Remove()

    local W, H = frame:GetSize()
    local textentries = {}
    if ... then 
        for i, v in ipairs( args ) do
            local textentry = vgui.Create( "GNTextEntry", frame )
            textentry:SetPos( 15, 30 * i + 15 * ( i - 1 ) )
            textentry:SetWide( W / 1.5 )
            textentry:CenterHorizontal()
            textentry:SetColor( GNLib.Colors.Silver )
            textentry:SetHoveredColor( GNLib.Colors.Clouds )

            if string.find( v:lower(), "url" ) then textentry.AllowInput = function() return false end end -- don't delete characters if you pass the size of the textentry
            if string.find( v:lower(), "::" ) then
                local args = string.Split( v, "::" )
                local placeholder = args[2]
                if placeholder then textentry:SetPlaceholder( placeholder ) end
            end

            local start = v:find( "::" )
            textentry:SetTitle( start and v:sub( 1, start - 1 ) or v )

            table.insert( textentries, textentry )
        end
    end

    local accept_button = vgui.Create( "GNButton", frame )
        accept_button:SetPos( W / 2 - accept_button:GetWide() - 15, H - accept_button:GetTall() - 7 )
        accept_button:SetText( confirm_text )
        accept_button:SetTextColor( color_white )
        accept_button:SetHoveredTextColor( color_white )
        accept_button:SetColor( GNLib.Colors.Emerald )
        accept_button:SetHoveredColor( GNLib.Colors.Nephritis )
        function accept_button:DoClick()
            frame:Remove()
            
            local values = {}
            for k, v in pairs( textentries ) do 
                if #v:GetValue() > 0 then table.insert( values, v:GetValue() ) else table.insert( values, v:GetPlaceholder() ) end
            end
            if callback then callback( unpack( values ) ) end
        end

    local cancel_button = vgui.Create( "GNButton", frame )
        cancel_button:SetPos( W / 2 + 15, H - cancel_button:GetTall() - 7 )
        cancel_button:SetText( cancel_text )
        cancel_button:SetTextColor( color_white )
        cancel_button:SetHoveredTextColor( color_white )
        cancel_button:SetColor( GNLib.Colors.Alizarin )
        cancel_button:SetHoveredColor( GNLib.Colors.Pomegranate )
        function cancel_button:DoClick()
            frame:Remove()
        end

    return frame
end

function GNLib.OpenURL( url )
    local frame = GNLib.CreateFrame( url )

    local controller = frame:Add( "DHTMLControls" )
    controller:Dock( TOP )
    controller:DockMargin( 5, 5, 5, 0 )

    local browser = frame:Add( "DHTML" )
    browser:Dock( FILL )
    browser:DockMargin( 5, 0, 5, 5 )
    browser:OpenURL( url )
    function browser:OnChangeTitle( title )
        frame:SetTitle( title )
    end

    controller:SetHTML( browser )
end

concommand.Add( "gnlib_resetpanels", function() 
    for i, v in ipairs( vgui.GetWorldPanel():GetChildren() ) do
        if v:IsVisible() then
            v:Remove()
        end
    end
end )
