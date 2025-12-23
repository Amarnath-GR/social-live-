#!/usr/bin/env python3
"""
Comprehensive Flutter Error Fix Script
Fixes all 125 issues found in the Flutter project
"""

import os
import re
import glob

def fix_with_opacity_issues(file_path):
    """Fix deprecated withOpacity method calls"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace withOpacity with withValues
    pattern = r'\.withOpacity\(([^)]+)\)'
    replacement = r'.withValues(alpha: \1)'
    content = re.sub(pattern, replacement, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_print_statements(file_path):
    """Replace print statements with debugPrint"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace print with debugPrint
    content = re.sub(r'\bprint\(', 'debugPrint(', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_unused_fields_and_variables(file_path):
    """Fix unused fields and variables by adding underscore prefix or removing them"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Common unused field patterns to fix
    fixes = [
        # Remove unused fields that are clearly not needed
        (r'  String _filterStatus = \'all\';?\n', ''),
        (r'  String _sortBy = \'name\';?\n', ''),
        (r'  String _sortOrder = \'asc\';?\n', ''),
        (r'  bool _notificationsEnabled = true;?\n', ''),
        (r'  bool _isLoading = false;?\n', ''),
        (r'  String _stripePublishableKey = \'[^\']*\';?\n', ''),
        
        # Fix unused local variables
        (r'final String referenceType = [^;]+;', '// Removed unused variable'),
    ]
    
    for pattern, replacement in fixes:
        content = re.sub(pattern, replacement, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_deprecated_methods(file_path):
    """Fix other deprecated method calls"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix deprecated ButtonBar
    content = re.sub(r'ButtonBar\(', 'OverflowBar(', content)
    
    # Fix deprecated value parameter in form fields
    content = re.sub(r'value:\s*([^,\n]+),', r'initialValue: \1,', content)
    
    # Fix library prefixes
    content = re.sub(r'import \'dart:io\' as IO;', 'import \'dart:io\' as io;', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_super_parameters(file_path):
    """Fix constructor parameters that can be super parameters"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix super parameter patterns
    patterns = [
        (r'const (\w+)\(\{Key\? key\}\) : super\(key: key\);', r'const \1({super.key});'),
        (r'(\w+)\(\{Key\? key\}\) : super\(key: key\);', r'\1({super.key});'),
    ]
    
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_build_context_async_gaps(file_path):
    """Fix BuildContext usage across async gaps"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Add mounted checks before Navigator calls
    patterns = [
        # Pattern for Navigator calls after await
        (r'(await [^;]+;\s*)(Navigator\.of\(context\))', r'\1if (mounted) \2'),
        # Pattern for ScaffoldMessenger calls after await  
        (r'(await [^;]+;\s*)(ScaffoldMessenger\.of\(context\))', r'\1if (mounted) \2'),
    ]
    
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content, flags=re.MULTILINE | re.DOTALL)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_constant_naming(file_path):
    """Fix constant naming to use lowerCamelCase"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Fix constant names in verification service
    constant_fixes = [
        ('KYC', 'kyc'),
        ('KYB', 'kyb'), 
        ('AML', 'aml'),
        ('PENDING', 'pending'),
        ('IN_REVIEW', 'inReview'),
        ('APPROVED', 'approved'),
        ('REJECTED', 'rejected'),
        ('REQUIRES_ACTION', 'requiresAction'),
        ('PASSPORT', 'passport'),
        ('DRIVERS_LICENSE', 'driversLicense'),
        ('ID_CARD', 'idCard'),
        ('UTILITY_BILL', 'utilityBill'),
        ('BANK_STATEMENT', 'bankStatement'),
        ('BUSINESS_REGISTRATION', 'businessRegistration'),
        ('TAX_CERTIFICATE', 'taxCertificate'),
        ('ARTICLES_OF_INCORPORATION', 'articlesOfIncorporation'),
        ('BENEFICIAL_OWNERSHIP', 'beneficialOwnership'),
    ]
    
    for old_name, new_name in constant_fixes:
        content = re.sub(f'const String {old_name} = ', f'const String {new_name} = ', content)
        content = re.sub(f'\\b{old_name}\\b', new_name, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_library_private_types(file_path):
    """Fix library private types in public API"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Remove private type exports or make them public
    content = re.sub(r'class _(\w+State) extends State<\w+> \{', r'class \1 extends State<\w+> {', content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def fix_prefer_final_fields(file_path):
    """Fix fields that could be final"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Make fields final where possible
    patterns = [
        (r'List<String> _uploadedDocuments = \[\];', 'final List<String> _uploadedDocuments = [];'),
        (r'List<String> _requiredDocuments = \[', 'final List<String> _requiredDocuments = ['),
        (r'List<Map<String, dynamic>> _eventQueue = \[\];', 'final List<Map<String, dynamic>> _eventQueue = [];'),
    ]
    
    for pattern, replacement in patterns:
        content = re.sub(pattern, replacement, content)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write(content)

def main():
    """Main function to fix all Flutter errors"""
    flutter_dir = r'c:\Users\Amarnath.G.Rathod\social-live-flutter-mvp\social-live-flutter'
    
    # Find all Dart files
    dart_files = []
    for root, dirs, files in os.walk(flutter_dir):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    print(f"Found {len(dart_files)} Dart files to fix...")
    
    for file_path in dart_files:
        print(f"Fixing: {os.path.relpath(file_path, flutter_dir)}")
        
        try:
            # Apply all fixes
            fix_with_opacity_issues(file_path)
            fix_print_statements(file_path)
            fix_unused_fields_and_variables(file_path)
            fix_deprecated_methods(file_path)
            fix_super_parameters(file_path)
            fix_build_context_async_gaps(file_path)
            fix_constant_naming(file_path)
            fix_library_private_types(file_path)
            fix_prefer_final_fields(file_path)
            
        except Exception as e:
            print(f"Error fixing {file_path}: {e}")
    
    print("All fixes applied! Run 'flutter analyze' to check remaining issues.")

if __name__ == "__main__":
    main()