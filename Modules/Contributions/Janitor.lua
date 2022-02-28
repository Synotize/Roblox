-- [Module Documents] : [https://devforum.community/t/janitor-a-better-garbage-collection-solution/338]
local Janitor; do
    local IndicesReference = newproxy(true)
    getmetatable(IndicesReference).__tostring = function()
        return "IndicesReference"
    end

    local LinkToInstanceIndex = newproxy(true)
    getmetatable(LinkToInstanceIndex).__tostring = function()
        return "LinkToInstanceIndex"
    end

    local METHOD_NOT_FOUND_ERROR = "Object %s doesn't have method %s, are you sure you want to add it? Traceback: %s"

    local janitor = {
        ClassName = "Janitor";
        __index = {
            CurrentlyCleaning = true;
            [IndicesReference] = nil;
        };
    }

    local TypeDefaults = {
        ["function"] = true;
        RBXScriptConnection = "Disconnect";
    }

    function janitor.new()
        return setmetatable({
            CurrentlyCleaning = false;
            [IndicesReference] = nil;
        }, janitor)
    end

    function janitor.Is(Object)
        return type(Object) == "table" and getmetatable(Object) == janitor
    end

    function janitor.__index:Add(Object, MethodName, Index)
        if Index then
            self:Remove(Index)

            local This = self[IndicesReference]
            if not This then
                This = {}
                self[IndicesReference] = This
            end

            This[Index] = Object
        end

        MethodName = MethodName or TypeDefaults[typeof(Object)] or "Destroy"
        if type(Object) ~= "function" and not Object[MethodName] then
            warn(string.format(METHOD_NOT_FOUND_ERROR, tostring(Object), tostring(MethodName), debug.traceback(nil, 2)))
        end

        self[Object] = MethodName
        return Object
    end

    function janitor.__index:Remove(Index)
        local This = self[IndicesReference]

        if This then
            local Object = This[Index]

            if Object then
                local MethodName = self[Object]

                if MethodName then
                    if MethodName == true then
                        Object()
                    else
                        local ObjectMethod = Object[MethodName]
                        if ObjectMethod then
                            ObjectMethod(Object)
                        end
                    end

                    self[Object] = nil
                end

                This[Index] = nil
            end
        end

        return self
    end

    function janitor.__index:Get(Index)
        local This = self[IndicesReference]
        if This then
            return This[Index]
        else
            return nil
        end
    end

    function janitor.__index:Cleanup()
        if not self.CurrentlyCleaning then
            self.CurrentlyCleaning = nil
            for Object, MethodName in next, self do
                if Object == IndicesReference then
                    continue
                end

                if MethodName == true then
                    Object()
                else
                    local ObjectMethod = Object[MethodName]
                    if ObjectMethod then
                        ObjectMethod(Object)
                    end
                end

                self[Object] = nil
            end

            local This = self[IndicesReference]
            if This then
                for Index in next, This do
                    This[Index] = nil
                end

                self[IndicesReference] = {}
            end

            self.CurrentlyCleaning = false
        end
    end

    function janitor.__index:Destroy()
        self:Cleanup()
        table.clear(self)
        setmetatable(self, nil)
    end

    janitor.__call = janitor.__index.Cleanup

    local Disconnect = {Connected = true}
    Disconnect.__index = Disconnect
    function Disconnect:Disconnect()
        if self.Connected then
            self.Connected = false
            self.Connection:Disconnect()
        end
    end

    function Disconnect:__tostring()
        return "Disconnect<" .. tostring(self.Connected) .. ">"
    end

    function janitor.__index:LinkToInstance(Object, AllowMultiple)
        local Connection
        local IndexToUse = AllowMultiple and newproxy(false) or LinkToInstanceIndex
        local IsNilParented = Object.Parent == nil
        local ManualDisconnect = setmetatable({}, Disconnect)

        local function ChangedFunction(_DoNotUse, NewParent)
            if ManualDisconnect.Connected then
                _DoNotUse = nil
                IsNilParented = NewParent == nil

                if IsNilParented then
                    task.defer(function()
                        if not ManualDisconnect.Connected then
                            return
                        elseif not Connection.Connected then
                            self:Cleanup()
                        else
                            while IsNilParented and Connection.Connected and ManualDisconnect.Connected do
                                task.wait()
                            end

                            if ManualDisconnect.Connected and IsNilParented then
                                self:Cleanup()
                            end
                        end
                    end)
                end
            end
        end

        Connection = Object.AncestryChanged:Connect(ChangedFunction)
        ManualDisconnect.Connection = Connection

        if IsNilParented then
            ChangedFunction(nil, Object.Parent)
        end

        Object = nil
        return self:Add(ManualDisconnect, "Disconnect", IndexToUse)
    end

    function janitor.__index:LinkToInstances(...)
        local ManualCleanup = Janitor.new()
        for _, Object in ipairs({...}) do
            ManualCleanup:Add(self:LinkToInstance(Object, true), "Disconnect")
        end

        return ManualCleanup
    end

    Janitor = janitor
end
