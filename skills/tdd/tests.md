# Test examples

## Through the interface, not around it

```typescript
// Bad: verifies through the database instead of the interface
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// Good: what a caller can observe
test("created user can be fetched", async () => {
  const user = await createUser({ name: "Alice" });
  expect((await getUser(user.id)).name).toBe("Alice");
});
```

## Behaviour, not calls

```typescript
// Bad: breaks on any refactor of how checkout pays
test("checkout calls paymentService.process", async () => {
  const pay = jest.mock(paymentService);
  await checkout(cart, card);
  expect(pay.process).toHaveBeenCalledWith(cart.total);
});

// Good
test("user can check out with a valid cart", async () => {
  const result = await checkout(cartWith(product), card);
  expect(result.status).toBe("confirmed");
});
```

## Independent expected values

```typescript
// Bad: recomputes the answer the way the code does
const expected = items.reduce((sum, i) => sum + i.price, 0);
expect(calculateTotal(items)).toBe(expected);

// Good
expect(calculateTotal([{ price: 10 }, { price: 5 }])).toBe(15);
```

## Making boundaries mockable

Pass external clients in instead of building them inside:

```typescript
function processPayment(order, paymentClient) {
  return paymentClient.charge(order.total);
}
```

Prefer one function per external operation (`getUser`, `createOrder`) over one generic `fetch(endpoint, options)`, so each mock returns one shape with no branching in test setup.
