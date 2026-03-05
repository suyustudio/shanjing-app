.class public abstract Lj1/o;
.super Lkotlinx/coroutines/internal/m;
.source "SourceFile"

# interfaces
.implements Lj1/q;


# annotations
.annotation system Ldalvik/annotation/Signature;
    value = {
        "<E:",
        "Ljava/lang/Object;",
        ">",
        "Lkotlinx/coroutines/internal/m;",
        "Lj1/q<",
        "TE;>;"
    }
.end annotation


# direct methods
.method public constructor <init>()V
    .locals 0

    invoke-direct {p0}, Lkotlinx/coroutines/internal/m;-><init>()V

    return-void
.end method


# virtual methods
.method public bridge synthetic e()Ljava/lang/Object;
    .locals 1

    invoke-virtual {p0}, Lj1/o;->y()Lkotlinx/coroutines/internal/x;

    move-result-object v0

    return-object v0
.end method

.method public y()Lkotlinx/coroutines/internal/x;
    .locals 1

    sget-object v0, Lj1/b;->b:Lkotlinx/coroutines/internal/x;

    return-object v0
.end method

.method public abstract z(Lj1/j;)V
    .annotation system Ldalvik/annotation/Signature;
        value = {
            "(",
            "Lj1/j<",
            "*>;)V"
        }
    .end annotation
.end method
