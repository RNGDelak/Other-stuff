import os
import re
import shutil
import win32com.client

# Target folder directory
script_dir = os.path.dirname(os.path.abspath(__file__))
luau_output_path = os.path.join(script_dir, "converted.luau")
temp_html_path = os.path.join(script_dir, "temp_export.html")

# Number of files to process
TOTAL_FILES = 259

# Start Word COM Application once
word = win32com.client.Dispatch("Word.Application")
word.Visible = False

try:
    with open(luau_output_path, "w", encoding="utf-8") as luau_file:
        luau_file.write("return {\n")
        first_entry = True

        for i in range(1, TOTAL_FILES + 1):
            file_name = f"Large numbers volume {i}.docx"
            docx_path = os.path.join(script_dir, file_name)

            if not os.path.exists(docx_path):
                print(f"Skipping (not found): {file_name}")
                continue

            print(f"Processing ({i}/{TOTAL_FILES}): {file_name}...")

            doc = word.Documents.Open(docx_path)
            
            # 1. Force Word to export as UTF-8 encoding (msoEncodingUTF8 = 65001)
            doc.WebOptions.Encoding = 65001
            doc.SaveAs2(temp_html_path, FileFormat=10)  # 10 = wdFormatFilteredHTML
            doc.Close()

            # 2. Read HTML strictly as UTF-8 (do not ignore errors)
            with open(temp_html_path, "r", encoding="utf-8") as f:
                raw_html = f.read()

            paragraphs = re.findall(r'<p\b[^>]*>.*?</p>', raw_html, flags=re.DOTALL)

            # 3. Stream each paragraph directly to the Luau file
            for p in paragraphs:
                p_clean = p.strip()
                if p_clean:
                    if not first_entry:
                        luau_file.write(",\n")
                    
                    # Escape multiline closing brackets if they exist inside paragraph text
                    p_safe = p_clean.replace("]]", "] ]")
                    luau_file.write(f"\t[[\n{p_safe}\n]]")
                    first_entry = False

            luau_file.flush()

            # Clean up temporary HTML file and asset folder
            if os.path.exists(temp_html_path):
                os.remove(temp_html_path)

            temp_files_folder = os.path.join(script_dir, "temp_export_files")
            if os.path.exists(temp_files_folder):
                shutil.rmtree(temp_files_folder, ignore_errors=True)

        luau_file.write("\n}\n")

finally:
    word.Quit()

print(f"\nSuccessfully generated {luau_output_path}!")