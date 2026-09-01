def main(context):
    context.log("========================================")
    context.log("TR STORAGE EVENT PROBE")
    context.log("EVENT PROBE RECEIVED")
    context.log("METHOD: " + str(context.req.method))
    context.log("PATH: " + str(context.req.path))
    context.log("BODY: " + str(context.req.body))
    context.log("HEADERS: " + str(context.req.headers))
    context.log("========================================")

    return context.res.json({
        "success": True,
        "service": "storage-event-probe",
        "eventReceived": True
    })
