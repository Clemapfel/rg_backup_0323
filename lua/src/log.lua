log = {}

log._error_label = "[ERROR]"
log._warning_label = "[WARNING]"
log._info_label = "[LOG]"

log.INFO = 0
log.WARNING = 1
log.ERROR = -1

--- @brief print to log
--- @param message string
--- @param level number: one of log.INFO, log.WARNING or log.ERROR
function log.print(message, level)

    if level == nil then level = log.INFO end

    local message_buffer = {}
    if level == log.INFO then
        table.insert(message_buffer, log._info_label)
    elseif level == log.WARNING then
        table.insert(message_buffer, log._warning_label)
    elseif level == log.ERROR then
        table.insert(message_buffer, log._error_label)
    end

    table.insert(message_buffer, " " .. message)
    io.write(table.concat(message_buffer), "\n")
end

--- @brief print as info
--- @param message string
function log.info(message)
    log.print(message, log.INFO)
end

--- @brief print as warning
--- @param message string
function log.warning(message)
    log.print(message, log.WARNING)
end

--- @brief print as error
--- @param message string
function log.error(message)
    log.print(message, log.ERROR)
end

function log._test()
    test.start_test("log")

    test.assert_that_not_errors("non-string", log.print(1234))
    test.assert_that_errors("non-level error", log.print("test", 4))
    test.assert_that_not_errors("info",  log.info("Info Message"))
    test.assert_that_not_errors("warning",  log.warning("Warning Message"))
    test.assert_that_not_errors("error",  log.error("Error Message"))

    test.end_test()
end