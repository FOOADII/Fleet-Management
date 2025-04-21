import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // System Messages
          'success': 'Success',
          'error': 'Error',
          'language_changed': 'Language changed successfully',

          // Auth
          'login': 'Login',
          'register': 'Register',
          'email': 'Email',
          'password': 'Password',
          'confirm_password': 'Confirm Password',
          'forgot_password': 'Forgot Password?',
          'sign_out': 'Sign Out',

          // Home
          'home': 'Home',
          'tasks': 'Tasks',
          'tracking': 'Tracking',
          'maintenance': 'Maintenance',
          'expenses': 'Expenses',
          'reports': 'Reports',
          'profile': 'Profile',

          // Tasks
          'add_task': 'Add Task',
          'edit_task': 'Edit Task',
          'delete_task': 'Delete Task',
          'task_title': 'Task Title',
          'task_description': 'Task Description',
          'due_date': 'Due Date',
          'priority': 'Priority',
          'status': 'Status',
          'assigned_to': 'Assigned To',
          'vehicle': 'Vehicle',

          // Maintenance
          'add_maintenance': 'Add Maintenance',
          'edit_maintenance': 'Edit Maintenance',
          'delete_maintenance': 'Delete Maintenance',
          'maintenance_title': 'Maintenance Title',
          'maintenance_description': 'Maintenance Description',
          'scheduled_date': 'Scheduled Date',
          'estimated_cost': 'Estimated Cost',

          // Expenses
          'add_expense': 'Add Expense',
          'edit_expense': 'Edit Expense',
          'delete_expense': 'Delete Expense',
          'expense_title': 'Expense Title',
          'expense_description': 'Expense Description',
          'amount': 'Amount',
          'category': 'Category',
          'date': 'Date',
          'receipt': 'Receipt',

          // Reports
          'generate_report': 'Generate Report',
          'report_title': 'Report Title',
          'report_description': 'Report Description',
          'report_type': 'Report Type',
          'start_date': 'Start Date',
          'end_date': 'End Date',

          // Profile
          'personal_info': 'Personal Information',
          'change_password': 'Change Password',
          'notifications': 'Notifications',
          'settings': 'Settings',
          'language': 'Language',
          'theme': 'Theme',
          'about': 'About',
          'help': 'Help',
          'contact': 'Contact',
        },
        'am_ET': {
          // System Messages
          'success': 'ተሳክቷል',
          'error': 'ስህተት',
          'language_changed': 'ቋንቋ በተሳካ ሁኔታ ተቀይሯል',

          // Auth
          'login': 'ግባ',
          'register': 'ተመዝግብ',
          'email': 'ኢሜይል',
          'password': 'የይለፍ ቃል',
          'confirm_password': 'የይለፍ ቃል አረጋግጥ',
          'forgot_password': 'የይለፍ ቃልዎን ረሳችሁ?',
          'sign_out': 'ውጣ',

          // Home
          'home': 'ቤት',
          'tasks': 'ተግባራት',
          'tracking': 'ክትትል',
          'maintenance': 'ጥገና',
          'expenses': 'ወጪዎች',
          'reports': 'ሪፖርቶች',
          'profile': 'መገለጫ',

          // Tasks
          'add_task': 'ተግባር ጨምር',
          'edit_task': 'ተግባር አስተካክል',
          'delete_task': 'ተግባር ሰርዝ',
          'task_title': 'የተግባር ስም',
          'task_description': 'የተግባር መግለጫ',
          'due_date': 'የመጨረሻ ቀን',
          'priority': 'ቅድመ ተራ',
          'status': 'ሁኔታ',
          'assigned_to': 'የተመደበ',
          'vehicle': 'ተሽከርካሪ',

          // Maintenance
          'add_maintenance': 'ጥገና ጨምር',
          'edit_maintenance': 'ጥገና አስተካክል',
          'delete_maintenance': 'ጥገና ሰርዝ',
          'maintenance_title': 'የጥገና ስም',
          'maintenance_description': 'የጥገና መግለጫ',
          'scheduled_date': 'የተወሰነ ቀን',
          'estimated_cost': 'የተገመተ ወጪ',

          // Expenses
          'add_expense': 'ወጪ ጨምር',
          'edit_expense': 'ወጪ አስተካክል',
          'delete_expense': 'ወጪ ሰርዝ',
          'expense_title': 'የወጪ ስም',
          'expense_description': 'የወጪ መግለጫ',
          'amount': 'መጠን',
          'category': 'ምድብ',
          'date': 'ቀን',
          'receipt': 'ደረሰኝ',

          // Reports
          'generate_report': 'ሪፖርት ፍጠር',
          'report_title': 'የሪፖርት ስም',
          'report_description': 'የሪፖርት መግለጫ',
          'report_type': 'የሪፖርት አይነት',
          'start_date': 'የመጀመሪያ ቀን',
          'end_date': 'የመጨረሻ ቀን',

          // Profile
          'personal_info': 'የግል መረጃ',
          'change_password': 'የይለፍ ቃል ቀይር',
          'notifications': 'ማስታወቂያዎች',
          'settings': 'ቅንብሮች',
          'language': 'ቋንቋ',
          'theme': 'ጨለማ/ብርሃን',
          'about': 'ስለ እኛ',
          'help': 'እርዳታ',
          'contact': 'አግኙን',
        },
        'om_ET': {
          // System Messages
          'success': 'Milkaa\'e',
          'error': 'Dogoggora',
          'language_changed': 'Afaan jijjiirameera',

          // Auth
          'login': 'Seeni',
          'register': 'Galmaa\'i',
          'email': 'Imeelii',
          'password': 'Jecha Iccitii',
          'confirm_password': 'Jecha Iccitii Mirkaneessi',
          'forgot_password': 'Jecha Iccitii Dagateeta?',
          'sign_out': 'Ba\'i',

          // Home
          'home': 'Mana',
          'tasks': 'Hojiileen',
          'tracking': 'Hordoffii',
          'maintenance': 'Suphaa',
          'expenses': 'Baasii',
          'reports': 'Gabaasa',
          'profile': 'Profaayilii',

          // Common actions
          'save': 'Olkaa\'i',
          'cancel': 'Dhiisi',
          'delete': 'Haqii',
          'edit': 'Gulaali',
          'add': 'Ida\'i',
        },
        'ti_ET': {
          // System Messages
          'success': 'ዕውት',
          'error': 'ጌጋ',
          'language_changed': 'ቋንቋ ብዓወት ተቐይሩ',

          // Auth
          'login': 'እቶ',
          'register': 'ምዝገባ',
          'email': 'ኢሜይል',
          'password': 'መሕለፊ ቃል',
          'confirm_password': 'መሕለፊ ቃል አረጋግጽ',
          'forgot_password': 'መሕለፊ ቃል ረሲዕካዮ?',
          'sign_out': 'ውጻእ',

          // Home
          'home': 'ገዛ',
          'tasks': 'ዕዮታት',
          'tracking': 'ክትትል',
          'maintenance': 'ጽገና',
          'expenses': 'ወጻኢታት',
          'reports': 'ጸብጻባት',
          'profile': 'መግለጺ',

          // Common actions
          'save': 'ዓቅብ',
          'cancel': 'ኣቋርጽ',
          'delete': 'ሰርዝ',
          'edit': 'ኣመዓራሪ',
          'add': 'ወስኽ',
        },
      };
}
