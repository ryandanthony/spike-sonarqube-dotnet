using System;
using Xunit;

namespace Spike.Tests
{
    public class UnitTest1
    {
        [Fact]
        public void Test1()
        {
            var c = new Class1();
            var x = c.Run();
            Assert.Equal("nothing", x);
        }
    }
}
