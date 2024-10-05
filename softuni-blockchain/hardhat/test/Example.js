const {
    loadFixture,
  } = require("@nomicfoundation/hardhat-toolbox/network-helpers");
  const { expect } = require("chai");
  
  describe("Example Contract", function () {
    async function deployExampleContract() {
      const Example = await ethers.getContractFactory("Example");
      const example = await Example.deploy(); // Deploy the contract
  
      return { example };
    }
  
    describe("Example person", function () {
        it("Should return true if age of person is 16", async function () {
            const { example } = await loadFixture(deployExampleContract); // Load fixture
            
            const person = await example.person(); // Fetch the 'person' struct from the contract
            
            expect(person.age).to.equal(16); // Check if the age is 16
          });
          it("Should return true if name of person is Tester", async function () {
            const { example } = await loadFixture(deployExampleContract); // Load fixture
            
            const person = await example.person(); // Fetch the 'person' struct from the contract
            
            expect(person.name).to.equal("Tester"); // Check if the name is Tester
          });
          it("Should return true if name of person is John after function called", async function () {
            const { example } = await loadFixture(deployExampleContract); // Load fixture
            
            await example.setDifferentName();

            const updatedPerson = await example.person(); // Fetch the 'person' struct from the contract

            expect(updatedPerson.name).to.equal("John"); // Check if the name is John
          });
    });
  });
  