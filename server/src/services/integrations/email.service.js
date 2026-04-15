const nodemailer = require('nodemailer');
const config = require('../../config');

class EmailService {
    constructor() {
        this.transporter = nodemailer.createTransport({
            host: process.env.EMAIL_HOST || 'smtp.mailtrap.io',
            port: process.env.EMAIL_PORT || 2525,
            auth: {
                user: process.env.EMAIL_USER,
                pass: process.env.EMAIL_PASS
            }
        });
    }

    async sendPasswordReset(email, token) {
        const resetUrl = `${process.env.FRONTEND_URL || 'http://localhost:3000'}/reset-password?token=${token}`;

        const mailOptions = {
            from: '"OpenHealth Support" <support@openhealth.com>',
            to: email,
            subject: 'Password Reset Request - OpenHealth',
            html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #2c3e50;">OpenHealth</h2>
          <p>Hello,</p>
          <p>You requested a password reset. Please click the button below to reset your password. This link expires in 1 hour.</p>
          <div style="text-align: center; margin: 30px 0;">
            <a href="${resetUrl}" style="background-color: #0d6efd; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold;">Reset Password</a>
          </div>
          <p>If you did not request this, please ignore this email.</p>
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;" />
          <p style="font-size: 12px; color: #7f8c8d;">&copy; 2026 OpenHealth. All rights reserved.</p>
        </div>
      `
        };

        try {
            await this.transporter.sendMail(mailOptions);
            console.log(`Password reset email sent to ${email}`);
        } catch (error) {
            console.error('Error sending password reset email:', error);
            throw error;
        }
    }

    async sendApprovalNotification(email, firstName, approved) {
        const subject = approved ? 'Account Approved - OpenHealth' : 'Account Update - OpenHealth';
        const message = approved
            ? `Congratulations ${firstName}, your account has been approved! You can now log in to the portal.`
            : `Hello ${firstName}, we regret to inform you that your registration request was not approved at this time.`;

        const mailOptions = {
            from: '"OpenHealth Support" <support@openhealth.com>',
            to: email,
            subject: subject,
            html: `
        <div style="font-family: sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
          <h2 style="color: #2c3e50;">OpenHealth</h2>
          <p>Hello ${firstName},</p>
          <p>${message}</p>
          ${approved ? `
          <div style="text-align: center; margin: 30px 0;">
            <a href="${process.env.FRONTEND_URL || 'http://localhost:3000'}/login" style="background-color: #198754; color: white; padding: 12px 24px; text-decoration: none; border-radius: 5px; font-weight: bold;">Login Now</a>
          </div>` : ''}
          <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;" />
          <p style="font-size: 12px; color: #7f8c8d;">&copy; 2026 OpenHealth. All rights reserved.</p>
        </div>
      `
        };

        try {
            await this.transporter.sendMail(mailOptions);
            console.log(`Approval email sent to ${email}`);
        } catch (error) {
            console.error('Error sending approval email:', error);
            throw error;
        }
    }
}

module.exports = new EmailService();
