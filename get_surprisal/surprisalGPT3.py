
from gpt3query import query


def get_text_surprisal(text, encode='utf-8', decode='utf-8'):
	'''
	Given text input, return model results as a list of tuples (token, logprob).
	'''
	result = []
	lines = query(text, write_metadata=False, encode=encode, decode=decode)
	lines_iter = iter(lines)
	for line in lines_iter:
		token, logprob, offset = line['token'].strip(), line['logprob'], line['offset']
		result.append((token, logprob, offset))
	result = handle_byte_tokens(result)

	return result


def handle_byte_tokens(model_output):
	'''
	Deal with byte tokens in GPT3 output ('bytes:\\x', 
	or 'bytes: \\x' when there a space before the token)
	'''
	result = []
	byte_tokens, byte_logps = [], []
	last_offset = -1
	for t, logp, o in model_output:
		current_offset = o
		if current_offset == last_offset:   # it must be bytes in this situation
			try:
				indices = [i for i, letter in enumerate(t) if letter == 'x']
				for i in indices:
					char_int = int(t[i+1:i+3], base=16)
					byte_tokens.append(bytes([char_int]))
				byte_logps.append(logp)
			except ValueError:
				print("Can't decode this token: {}".format(t))
		else:
			if len(byte_tokens) != 0:   # first deal with elements in the bytes buffer
				try:
					utf_token = b''.join(byte_tokens).decode()
					if None in byte_logps:
						utf_logp = None
					else:
						utf_logp = sum(byte_logps)
					result.append((utf_token, utf_logp))
				except ValueError:
					print("Can't decode this token: {}".format(b''.join(byte_tokens)))
					result.append((None, None))
				byte_tokens, byte_logps = [], []
			
			# deal with the current token
			if t.startswith('bytes: \\x') or t.startswith('bytes:\\x'):
				try:
					indices = [i for i, letter in enumerate(t) if letter == 'x']
					for i in indices:
						char_int = int(t[i+1:i+3], base=16)
						byte_tokens.append(bytes([char_int]))
					byte_logps.append(logp)
				except ValueError:
					print("Can't decode this token: {}".format(t))
			else:
				try:
					t = t.encode('latin-1').decode('utf-8')
					result.append((t, logp))
				except ValueError:
					print("Can't decode this token: {}".format(t))
					result.append((t, None))
		last_offset = o

	return result










