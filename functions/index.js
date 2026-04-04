const { onValueWritten } = require("firebase-functions/database");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");

admin.initializeApp();

exports.notifyAdminOnNewMessage = onValueWritten(
  "/messages/{messageId}",
  async (event) => {
    const before = event.data.before.val();
    const after = event.data.after.val();

    // لو مفيش داتا بعد → تجاهل
    if (!after) return null;

    // 🔥 الشرط المهم
    // ابعت إشعار لو:
    // - رسالة جديدة
    // - أو read بقت false
    const isNewMessage = !before;
    const becameUnread = before && before.read === true && after.read === false;

    if (!isNewMessage && !becameUnread) {
      return null;
    }

    const senderName = after.name || "Visitor";
    const subject = after.subject || after.message || "New message";

    const tokensSnap = await admin.database().ref("admin_tokens").get();

    if (!tokensSnap.exists()) {
      logger.log("No tokens found");
      return null;
    }

    const tokens = Object.values(tokensSnap.val()).map(t => t.token);

    if (!tokens.length) return null;

    await admin.messaging().sendEachForMulticast({
      tokens,
      notification: {
        title: `A new message from ${senderName}`,
        body: subject.substring(0, 100),
      },
      data: {
        type: "new_message",
        messageId: event.params.messageId,
      },
      android: {
        priority: "high",
        notification: {
          channelId: "portfolio_messages",
          clickAction: "FLUTTER_NOTIFICATION_CLICK",
        },
      },
    });

    logger.log("Notification sent 🔥");
    return null;
  }
);