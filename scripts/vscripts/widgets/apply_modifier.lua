------------------------------------------------
--               Global item applier          --
------------------------------------------------
function ApplyModifier(unit, modifier_name, duration)
    if duration then
        GameRules.APPLIER:ApplyDataDrivenModifier(unit, unit, modifier_name, {duration=duration})
    else
        GameRules.APPLIER:ApplyDataDrivenModifier(unit, unit, modifier_name, {})
    end
end