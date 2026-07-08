from transformers import pipeline

print("hello?")

# Load the default English-to-French translation pipeline
# This typically uses a model like t5-base or Helsinki-NLP/opus-mt-en-fr under the hood
en_fr_translator = pipeline("translation_en_to_fr")

# Text to translate
text_to_translate = "Hello, how are you today?"

# Perform the translation
result = en_fr_translator(text_to_translate)

# Print the translated text
print(result[0]["translation_text"])
