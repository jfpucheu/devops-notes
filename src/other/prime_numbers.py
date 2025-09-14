import time

def is_prime(n):
    if n <= 1:
        return False
    if n == 2:
        return True
    if n % 2 == 0:
        return False
    for i in range(3, int(n**0.5)+1, 2):
        if n % i == 0:
            return False
    return True

start_time = time.time()

# Generate prime numbers up to 50 million
limit = 50_000_000
primes = [n for n in range(2, limit) if is_prime(n)]

end_time = time.time()

print(f"Generated {len(primes)} prime numbers up to {limit}.")
print(f"Time taken: {end_time - start_time:.2f} seconds.")
